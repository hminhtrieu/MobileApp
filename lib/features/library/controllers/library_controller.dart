import 'package:flashcard/features/documents/model/document_model.dart';

class LibraryController {
  static Future<List<Map<String, dynamic>>> fetchAllDocuments() async {
    return await DocumentModel.dbGetAllDocumentsWithSubject();
  }
}
