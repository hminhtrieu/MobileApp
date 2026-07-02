import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flashcard/core/database/sync_controller.dart';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flutter/material.dart';

class DocumentListController extends ChangeNotifier {
  final int subjectId;
  final SyncController _syncController = SyncController();
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DocumentModel> _documents = [];
  List<DocumentModel> get documents => _documents;

  DocumentListController(this.subjectId) {
    refreshDocuments();
  }

  Future<void> refreshDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docs = await DocumentModel.dbGetDocumentsBySubject(subjectId);
      _documents = docs;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống nạp học liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(int docId) async {
    try {
      await DocumentModel.dbDeleteDocument(docId);
      await refreshDocuments();
    } catch (e) {
      throw 'Không thể xóa chủ đề. Vui lòng thử lại.';
    }
  }

  Future<void> renameDocument(int docId, String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      await DocumentModel.dbUpdateDocumentName(docId, newName.trim());
      await refreshDocuments();
    } catch (e) {
      throw 'Không thể đổi tên chủ đề. Vui lòng thử lại.';
    }
  }

  Future<void> uploadAdditionalDocument(DocumentModel doc) async {
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'documents',
        extensions: <String>['pdf', 'doc', 'docx', 'txt'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file == null) return; // Hủy chọn file

      final int length = await file.length();
      if (length > 3 * 1024 * 1024) {
        throw 'Kích thước tệp vượt quá 3MB. Vui lòng chọn tệp nhỏ hơn để hệ thống AI xử lý.';
      }

      // Throw a specific custom exception so UI can catch it and show loading
      throw 'START_UPLOAD:${file.path}|${file.name}';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> processAdditionalUpload(DocumentModel doc, String filePath, String fileName) async {
    try {
      final url = 'http://192.168.1.2:5678/webhook-test/upload-document';
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 90);
      dio.options.receiveTimeout = const Duration(seconds: 90);

      FormData formData = FormData.fromMap({
        'document_id': doc.documentId.toString(),
        'subject_id': subjectId.toString(),
        'folder_name': doc.folderName,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> n8nRawResponse = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        bool isSyncSuccess = await _syncController.importN8nDataToDatabase(
          doc.documentId!,
          n8nRawResponse,
        );

        if (isSyncSuccess) {
          await DocumentModel.dbUpdateDocumentFile(doc.documentId!, fileName, filePath);
          await refreshDocuments();
        } else {
          throw 'Hệ thống không thể xử lý dữ liệu trả về từ AI. Vui lòng thử lại sau.';
        }
      } else {
        throw 'Máy chủ AI đang quá tải hoặc gặp sự cố. Vui lòng thử lại sau.';
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          throw 'Máy chủ AI đang xử lý quá lâu hoặc quá tải (Timeout). Vui lòng thử lại.';
        } else if (e.type == DioExceptionType.connectionError) {
          throw 'Không thể kết nối đến máy chủ n8n. Vui lòng kiểm tra lại server hoặc mạng internet.';
        } else if (e.response != null) {
          final statusCode = e.response!.statusCode;
          if (statusCode == 429) {
            throw 'Bạn đã gửi quá nhiều yêu cầu. Hệ thống AI đang bị giới hạn, vui lòng chờ một lát.';
          } else if (statusCode == 401 || statusCode == 403) {
            throw 'Hệ thống n8n báo lỗi xác thực hoặc đã hết Token API của mô hình AI.';
          } else if (statusCode != null && statusCode >= 500) {
            throw 'Máy chủ n8n đang gặp lỗi nội bộ không thể xử lý ($statusCode).';
          } else {
            throw 'Máy chủ AI trả về lỗi không xác định ($statusCode).';
          }
        } else {
          throw 'Mất kết nối mạng khi đang xử lý hoặc server n8n chưa hoạt động.';
        }
      }
      if (e is String) throw e;
      throw 'Đã có lỗi hệ thống xảy ra trong quá trình xử lý.';
    }
  }
}
