import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';

class FlashcardController {
  final int documentId;

  List<Map<String, dynamic>> flashcards = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool isFlipped = false;

  FlashcardController({required this.documentId});

  // Nạp dữ liệu từ learning.db
  Future<void> loadFlashcards(VoidCallback onUpdate) async {
    try {
      isLoading = true;
      onUpdate();

      List<Map<String, dynamic>> rawFlashcards = await FlashcardModel.dbGetFlashcardsByDocument(documentId);
      
      // Tạo bản sao và xáo trộn ngẫu nhiên thứ tự thẻ
      flashcards = List<Map<String, dynamic>>.from(rawFlashcards);
      flashcards.shuffle();

      isLoading = false;
      onUpdate();
    } catch (e) {
      print('❌ Lỗi Controller khi load Flashcard: $e');
      isLoading = false;
      onUpdate();
    }
  }

  // Cập nhật mức độ ghi nhớ
  Future<void> updateMemoryLevel(
    int cardId,
    int newLevel,
    VoidCallback onUpdate,
  ) async {
    print(
      '🚀 [CONTROLLER EVENT] Nhận lệnh đánh giá Card ID: $cardId -> Mức độ: $newLevel',
    );

    try {
      await FlashcardModel.dbUpdateMemoryLevel(cardId, newLevel);

      print(
        '✅ Controller cập nhật thành công CSDL cho Card $cardId -> Level $newLevel',
      );

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

  // Trở về mặt trước khi đổi câu hỏi
  void nextCard(VoidCallback onUpdate) {
    currentIndex++;
    isFlipped = false;
    onUpdate();
  }

  // Tính % tiến độ học tập
  double get progressPercent {
    if (flashcards.isEmpty) return 0.0;
    if (currentIndex >= flashcards.length) return 1.0;
    return (currentIndex + 1) / flashcards.length;
  }
}
