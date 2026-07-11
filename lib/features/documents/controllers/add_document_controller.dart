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
          _setError(
            'Kích thước tệp vượt quá 3MB. Vui lòng chọn tệp nhỏ hơn để hệ thống AI xử lý.',
          );
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

  String _progressStatus = '';
  String get progressStatus => _progressStatus;

  void _setProgress(String status) {
    _progressStatus = status;
    notifyListeners();
  }

  Future<bool> uploadAndProcessDocument(int subjectId) async {
    _setError(null);
    _setProgress('');

    if (_pickedFile == null || _pickedFile!.path.isEmpty) {
      _setError('Vui lòng chọn một tệp tài liệu học tập!');
      return false;
    }

    final String themeName = themeNameController.text.trim();

    _isLoading = true;
    notifyListeners();

    int targetDocId = -1;

    try {
      final newDoc = DocumentModel(
        folderName: themeName,
        fileName: _pickedFile!.name,
        filePath: _pickedFile!.path,
        summaryContext: 'Đang xử lý...',
        createdAt: DateTime.now().toIso8601String(),
        subjectId: subjectId,
      );

      targetDocId = await DocumentModel.dbInsertDocument(newDoc);

      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 300);
      dio.options.receiveTimeout = const Duration(seconds: 300);

      // --- GỌI N8N TRONG 1 NHỊP DUY NHẤT ---
      _setProgress('Đang chờ AI phân tích (Có thể mất 1-2 phút)...');
      final url = 'http://127.0.0.1:5678/webhook-test/upload-document';

      FormData formData = FormData.fromMap({
        'document_id': targetDocId.toString(),
        'subject_id': subjectId.toString(),
        'folder_name': themeName,
        'file': MultipartFile.fromBytes(
          await _pickedFile!.readAsBytes(),
          filename: _pickedFile!.name,
        ),
      });

      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        var decodedData = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        Map<String, dynamic> n8nRawResponse;

        if (decodedData is List && decodedData.isNotEmpty) {
          // N8n thường hay trả về một mảng chứa 1 object
          n8nRawResponse = Map<String, dynamic>.from(decodedData.first);
        } else if (decodedData is Map) {
          n8nRawResponse = Map<String, dynamic>.from(decodedData);
        } else {
          throw FormatException(
            'Kiểu dữ liệu từ n8n không phải là JSON Object hoặc Array hợp lệ',
          );
        }

        bool isSyncSuccess = await _syncController.importN8nDataToDatabase(
          targetDocId,
          n8nRawResponse,
        );

        if (isSyncSuccess) {
          print('💾 SQLite đã ghi dữ liệu xong. Kích hoạt lệnh copy file...');
          await _cuopFileDatabase();
          _isLoading = false;
          _setProgress('');
          notifyListeners();
          return true;
        } else {
          await DocumentModel.dbDeleteDocument(targetDocId);
          _setError(
            'Lỗi phân rã cấu trúc JSON khi rải dữ liệu xuống CSDL cục bộ!',
          );
        }
      } else {
        await DocumentModel.dbDeleteDocument(targetDocId);
        _setError('Cổng n8n báo lỗi hệ thống: ${response.statusCode}');
      }
    } catch (e) {
      if (targetDocId != -1) {
        await DocumentModel.dbDeleteDocument(targetDocId);
      }

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          _setError('AI xử lý quá lâu (Timeout). Vui lòng thử lại.');
        } else if (e.type == DioExceptionType.connectionError) {
          _setError(
            'Không thể kết nối đến máy chủ n8n. Hãy kiểm tra lệnh adb reverse.',
          );
        } else {
          _setError(
            'Máy chủ AI báo lỗi: ${e.response?.statusCode ?? "Không xác định"}',
          );
        }
      } else {
        _setError('Lỗi hệ thống: $e');
      }

      _isLoading = false;
      _setProgress('');
      notifyListeners();
      return false;
    }

    _isLoading = false;
    _setProgress('');
    notifyListeners();
    return false;
  }
}
