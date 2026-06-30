import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flutter/material.dart';

class DocumentListController extends ChangeNotifier {
  final int subjectId;
  
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
}
