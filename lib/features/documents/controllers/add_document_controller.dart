import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flashcard/core/database/sync_controller.dart';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AddDocumentController extends ChangeNotifier {
  final SyncController _syncController = SyncController();
  final TextEditingController themeNameController = TextEditingController();

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  int _fileLengthInBytes = 0;
  int get fileLengthInBytes => _fileLengthInBytes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    themeNameController.dispose();
    super.dispose();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> pickRealFile() async {
    _setError(null);
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'documents',
        extensions: <String>['pdf', 'doc', 'docx', 'txt'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file != null) {
        final int length = await file.length();
        if (length > 3 * 1024 * 1024) {
          _setError('Kích thước tệp vượt quá 3MB. Vui lòng chọn tệp nhỏ hơn để hệ thống AI xử lý.');
          _pickedFile = null;
          _fileLengthInBytes = 0;
          notifyListeners();
          return;
        }
        
        _pickedFile = file;
        _fileLengthInBytes = length;
        notifyListeners();
      }
    } catch (e) {
      _setError('Không thể mở trình chọn file của thiết bị: $e');
    }
  }

  Future<void> _cuopFileDatabase() async {
    try {
      String docsPath = await getDatabasesPath();
      String sourcePath = p.join(docsPath, 'learning.db');
      String targetPath = '/sdcard/Download/learning_copy.db';

      File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
        print('🎉 [SUCCESS] App đã tự ném file DB ra thư mục Download chung!');
      } else {
        print('❌ Không tìm thấy file learning.db gốc ngầm!');
      }
    } catch (e) {
      print('Lỗi cướp file: $e');
    }
  }

  Future<bool> uploadAndProcessDocument(int subjectId) async {
    _setError(null);

    if (_pickedFile == null || _pickedFile!.path.isEmpty) {
      _setError('Vui lòng chọn một tệp tài liệu học tập thật!');
      return false;
    }

    final String themeName = themeNameController.text.trim();

    _isLoading = true;
    notifyListeners();

    try {
      final newDoc = DocumentModel(
        folderName: themeName,
        fileName: _pickedFile!.name,
        filePath: _pickedFile!.path,
        summaryContext: 'Đang chờ n8n AI phân tích...',
        createdAt: DateTime.now().toIso8601String(),
        subjectId: subjectId,
      );

      int targetDocId = await DocumentModel.dbInsertDocument(newDoc);

      try {
        final url = 'http://192.168.1.2:5678/webhook-test/upload-document';

        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 90);
        dio.options.receiveTimeout = const Duration(seconds: 90);

        FormData formData = FormData.fromMap({
          'document_id': targetDocId.toString(),
          'subject_id': subjectId.toString(),
          'folder_name': themeName,
          'file': await MultipartFile.fromFile(
            _pickedFile!.path,
            filename: _pickedFile!.name,
          ),
        });

        var response = await dio.post(url, data: formData);

        if (response.statusCode == 200) {
          final Map<String, dynamic> n8nRawResponse = response.data is String
              ? jsonDecode(response.data)
              : response.data;

          bool isSyncSuccess = await _syncController.importN8nDataToDatabase(
            targetDocId,
            n8nRawResponse,
          );

          if (isSyncSuccess) {
            print('💾 SQLite đã ghi dữ liệu xong. Kích hoạt lệnh copy file...');
            await _cuopFileDatabase();
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            await DocumentModel.dbDeleteDocument(targetDocId);
            _setError('Lỗi phân rã cấu trúc JSON khi rải dữ liệu xuống CSDL cục bộ!');
          }
        } else {
          await DocumentModel.dbDeleteDocument(targetDocId);
          _setError('Cổng n8n báo lỗi hệ thống: ${response.statusCode}');
        }
      } catch (e) {
        await DocumentModel.dbDeleteDocument(targetDocId);
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
            _setError('Máy chủ AI đang xử lý quá lâu hoặc quá tải (Timeout). Vui lòng thử lại.');
          } else if (e.type == DioExceptionType.connectionError) {
            _setError('Không thể kết nối đến máy chủ n8n. Vui lòng kiểm tra lại server hoặc mạng internet.');
          } else if (e.response != null) {
            final statusCode = e.response!.statusCode;
            if (statusCode == 429) {
              _setError('Bạn đã gửi quá nhiều yêu cầu. Hệ thống AI đang bị giới hạn, vui lòng chờ một lát.');
            } else if (statusCode == 401 || statusCode == 403) {
              _setError('Hệ thống n8n báo lỗi xác thực hoặc đã hết Token API của mô hình AI.');
            } else if (statusCode != null && statusCode >= 500) {
              _setError('Máy chủ n8n đang gặp lỗi nội bộ không thể xử lý ($statusCode).');
            } else {
              _setError('Máy chủ AI trả về lỗi không xác định ($statusCode).');
            }
          } else {
            _setError('Mất kết nối mạng khi đang xử lý hoặc server n8n chưa hoạt động.');
          }
        } else {
          _setError('Đã có lỗi hệ thống xảy ra trong quá trình xử lý luồng AI.');
        }
      }
    } catch (e) {
      _setError('Hệ thống gặp sự cố khi khởi tạo chủ đề mới.');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
