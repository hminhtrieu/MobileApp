import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class FlashcardController {
  final int documentId;

  List<Map<String, dynamic>> flashcards = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool isFlipped = false;

  FlashcardController({required this.documentId});

  // 🗄️ Nạp dữ liệu từ file learning.db
  Future<void> loadFlashcards(VoidCallback onUpdate) async {
    try {
      isLoading = true;
      onUpdate();

      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'learning.db');
      final Database db = await openDatabase(path);

      final result = await db.query(
        'Flashcard',
        where: 'document_id = ?',
        whereArgs: [documentId],
        orderBy: 'card_id ASC',
      );
      flashcards = List<Map<String, dynamic>>.from(result);

      isLoading = false;
      onUpdate();
    } catch (e) {
      print('❌ Lỗi Controller khi load Flashcard: $e');
      isLoading = false;
      onUpdate();
    }
  }

  // 💾 Cập nhật mức độ ghi nhớ xuống SQLite
  Future<void> updateMemoryLevel(
    int cardId,
    int newLevel,
    VoidCallback onUpdate,
  ) async {
    // 🌟 DÒNG THÁM TỬ: In ra Terminal để Triệu biết chắc chắn nút bấm đã thông sang Controller
    print(
      '🚀 [CONTROLLER EVENT] Nhận lệnh đánh giá Card ID: $cardId -> Mức độ: $newLevel',
    );

    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'learning.db');
      final Database db = await openDatabase(path);

      await db.update(
        'Flashcard',
        {
          'memory_level': newLevel,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'card_id = ?',
        whereArgs: [cardId],
      );

      print(
        '✅ Controller cập nhật thành công CSDL cho Card $cardId -> Level $newLevel',
      );
      
      // Logic lặp lại ngắt quãng dựa trên mức độ:
      // Khó (1) -> xuất hiện lại sớm (sau 2 thẻ)
      // Trung bình (2) -> xuất hiện lại muộn hơn (sau 5 thẻ)
      // Dễ (3) -> đẩy hẳn xuống cuối cùng
      final cardToRepeat = Map<String, dynamic>.from(flashcards[currentIndex]);
      
      if (newLevel == 1) {
        int insertIndex = currentIndex + 3;
        if (insertIndex > flashcards.length) insertIndex = flashcards.length;
        flashcards.insert(insertIndex, cardToRepeat);
      } else if (newLevel == 2) {
        int insertIndex = currentIndex + 6;
        if (insertIndex > flashcards.length) insertIndex = flashcards.length;
        flashcards.insert(insertIndex, cardToRepeat);
      } else if (newLevel == 3) {
        flashcards.add(cardToRepeat);
      }

      nextCard(onUpdate);
    } catch (e) {
      print('❌ Lỗi Controller khi lưu vào SQLite: $e');
    }
  }

  // 🔄 Logic chuyển thẻ tiếp theo
  void nextCard(VoidCallback onUpdate) {
    currentIndex++;
    isFlipped = false; // Trở về mặt trước khi đổi câu hỏi
    onUpdate();
  }

  // Tính % tiến độ học tập
  double get progressPercent {
    if (flashcards.isEmpty) return 0.0;
    if (currentIndex >= flashcards.length) return 1.0;
    return (currentIndex + 1) / flashcards.length;
  }
}
