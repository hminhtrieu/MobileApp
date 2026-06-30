import 'dart:convert';
import 'package:flashcard/core/database/database_helper.dart';

class SyncController {
  /// Kỹ thuật bóc tách double-decode: Giải mã cục output \n và đẩy vào SQLite
  Future<bool> importN8nDataToDatabase(
    int docId,
    Map<String, dynamic> n8nRawResponse,
  ) async {
    final db = await DatabaseHelper.instance.database;

    // Sử dụng Transaction bảo đảm tính toàn vẹn dữ liệu (Nếu lỗi một dòng, tự hủy toàn bộ chu kỳ ghi)
    return await db.transaction((txn) async {
      try {
        // 1. Kiểm tra sự tồn tại của trường dữ liệu "output" từ n8n
        if (!n8nRawResponse.containsKey('output')) {
          print("❌ Lỗi: Phản hồi thiếu cấu trúc trường 'output'");
          return false;
        }

        String outputString = n8nRawResponse['output'];

        // 2. GIẢI MÃ LẦN 2 (Double Decode): Biến chuỗi text chứa \n thành Map sạch
        Map<String, dynamic> cleanData = jsonDecode(outputString);

        // 3. CẬP NHẬT TÓM TẮT TÀI LIỆU ( summary_context)
        if (cleanData.containsKey('summary_context')) {
          String summary = cleanData['summary_context'];
          await txn.update(
            'Document',
            {'summary_context': summary},
            where: 'document_id = ?',
            whereArgs: [docId],
          );
        }

        String now = DateTime.now().toIso8601String();

        // 4. DUYỆT VÀ CHÈN LỚP FLASHCARD
        if (cleanData.containsKey('flashcards')) {
          List<dynamic> flashcardList = cleanData['flashcards'];

          for (var card in flashcardList) {
            await txn.insert('Flashcard', {
              'front_text': card['front_text'],
              'back_text': card['back_text'],
              'memory_level':
                  1, // Khởi tạo ở Hộp số 1 theo phương pháp Leitner[cite: 1]
              'created_at': now,
              'updated_at': now,
              'document_id': docId,
            });
          }
        }

        // 5. DUYỆT VÀ CHÈN LỚP QUIZ TRẮC NGHIỆM
        if (cleanData.containsKey('quizzes')) {
          List<dynamic> quizList = cleanData['quizzes'];

          for (var quiz in quizList) {
            // Chuẩn hóa trường correct_option từ chuỗi 'option_a' về ký tự 'A' để khớp thiết kế bảng[cite: 1]
            String rawCorrectOption = quiz['correct_option'] ?? 'option_a';
            String formattedOption = 'A';

            if (rawCorrectOption == 'option_b' || rawCorrectOption == 'B') {
              formattedOption = 'B';
            }
            if (rawCorrectOption == 'option_c' || rawCorrectOption == 'C') {
              formattedOption = 'C';
            }
            if (rawCorrectOption == 'option_d' || rawCorrectOption == 'D') {
              formattedOption = 'D';
            }

            await txn.insert('Quiz', {
              'question_content': quiz['question_content'],
              'option_a': quiz['option_a'],
              'option_b': quiz['option_b'],
              'option_c': quiz['option_c'],
              'option_d': quiz['option_d'],
              'correct_option':
                  formattedOption, // Lưu duy nhất ký tự 'A', 'B', 'C' hoặc 'D'[cite: 1]
              'created_at': now,
              'document_id': docId,
            });
          }
        }

        print(
          "🚀 [SQLITE SYNC] Đã rải phẳng toàn bộ học liệu của Document ID $docId xuống máy thành công!",
        );
        return true;
      } catch (e) {
        print("❌ Lỗi xảy ra trong tiến trình bóc tách đồng bộ dữ liệu: $e");
        return false; // Trả về false để Rollback lại database tránh sinh rác dữ liệu
      }
    });
  }
}
