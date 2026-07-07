import 'package:flashcard/core/database/database_helper.dart';

class LibraryController {
  static Future<List<Map<String, dynamic>>> fetchAllDocuments() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT d.*, s.subject_name 
      FROM Document d 
      JOIN Subject s ON d.subject_id = s.subject_id 
      ORDER BY d.created_at DESC
    ''');
    return maps;
  }
}
