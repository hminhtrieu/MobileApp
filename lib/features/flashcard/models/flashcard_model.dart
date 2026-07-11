import 'package:flashcard/core/database/database_helper.dart';

class FlashcardModel {
  final int? cardId;
  final String frontText;
  final String backText;
  int memoryLevel;
  final String createdAt;
  final String updatedAt;
  final int documentId;

  FlashcardModel({
    this.cardId,
    required this.frontText,
    required this.backText,
    required this.memoryLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.documentId,
  });

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      cardId: map['card_id'] as int?,
      frontText: map['front_text'] as String,
      backText: map['back_text'] as String,
      memoryLevel: map['memory_level'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      documentId: map['document_id'] as int,
    );
  }

  // Nạp dữ liệu từ file learning.db theo Document
  static Future<List<Map<String, dynamic>>> dbGetFlashcardsByDocument(int documentId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'Flashcard',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'card_id ASC',
    );
    return List<Map<String, dynamic>>.from(result);
  }

  // Cập nhật mức độ Leitner (Hộp 1 - 5)
  static Future<void> dbUpdateMemoryLevel(int id, int nextLevel) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'Flashcard',
      {
        'memory_level': nextLevel,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'card_id = ?',
      whereArgs: [id],
    );
  }
}
