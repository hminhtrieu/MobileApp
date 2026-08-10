import 'dart:convert';
import 'package:flashcard/core/database/database_helper.dart';

class SyncController {
  Future<bool> importN8nDataToDatabase(
    int docId,
    Map<String, dynamic> n8nRawResponse,
  ) async {
    final db = await DatabaseHelper.instance.database;

    // Sử dụng Transaction bảo đảm tính toàn vẹn dữ liệu
    return await db.transaction((txn) async {
      try {
        Map<String, dynamic> cleanData;
        if (n8nRawResponse.containsKey('output') &&
            n8nRawResponse['output'] is String) {
          try {
            cleanData = jsonDecode(n8nRawResponse['output']);
          } catch (e) {
            cleanData = n8nRawResponse;
          }
        } else {
          cleanData = n8nRawResponse;
        }

        //CẬP NHẬT TÓM TẮT TÀI LIỆU
        if (cleanData.containsKey('summary_context') &&
            cleanData['summary_context'] != null) {
          String summary = cleanData['summary_context'].toString();
          await txn.update(
            'Document',
            {'summary_context': summary},
            where: 'document_id = ?',
            whereArgs: [docId],
          );
        }

        String now = DateTime.now().toIso8601String();

        // DUYỆT VÀ CHÈN FLASHCARD
        if (cleanData.containsKey('flashcards')) {
          var rawCards = cleanData['flashcards'];
          List<dynamic> flashcardList = [];

          if (rawCards is String) {
            try {
              String cleanRaw = rawCards;
              final RegExp arrayRegExp = RegExp(r'\[.*\]', dotAll: true);
              final Match? match = arrayRegExp.firstMatch(cleanRaw);

              if (match != null) {
                cleanRaw = match.group(0)!;
              } else {
                final RegExp objRegExp = RegExp(r'\{.*\}', dotAll: true);
                final Match? objMatch = objRegExp.firstMatch(cleanRaw);
                if (objMatch != null) cleanRaw = objMatch.group(0)!;
              }

              var decoded = jsonDecode(cleanRaw);
              if (decoded is List)
                flashcardList = decoded;
              else if (decoded is Map && decoded.containsKey('flashcards'))
                flashcardList = decoded['flashcards'];
            } catch (e) {
              print('Lỗi parse flashcards string: $e');
            }
          } else if (rawCards is List) {
            flashcardList = rawCards;
          } else if (rawCards is Map && rawCards.containsKey('flashcards')) {
            flashcardList = rawCards['flashcards'];
          }

          for (var card in flashcardList) {
            if (card is Map) {
              String? front =
                  card['front_text']?.toString() ??
                  card['front']?.toString() ??
                  card['question']?.toString() ??
                  card['term']?.toString();
              String? back =
                  card['back_text']?.toString() ??
                  card['back']?.toString() ??
                  card['answer']?.toString() ??
                  card['definition']?.toString();

              await txn.insert('Flashcard', {
                'front_text': front ?? 'Nội dung trống',
                'back_text': back ?? 'Nội dung trống',
                'memory_level': 1,
                'created_at': now,
                'updated_at': now,
                'document_id': docId,
              });
            }
          }
        }

        // DUYỆT VÀ CHÈN QUIZ TRẮC NGHIỆM
        if (cleanData.containsKey('quizzes')) {
          var rawQuizzes = cleanData['quizzes'];
          List<dynamic> quizList = [];

          if (rawQuizzes is String) {
            try {
              String cleanRaw = rawQuizzes;
              final RegExp arrayRegExp = RegExp(r'\[.*\]', dotAll: true);
              final Match? match = arrayRegExp.firstMatch(cleanRaw);

              if (match != null) {
                cleanRaw = match.group(0)!;
              } else {
                final RegExp objRegExp = RegExp(r'\{.*\}', dotAll: true);
                final Match? objMatch = objRegExp.firstMatch(cleanRaw);
                if (objMatch != null) cleanRaw = objMatch.group(0)!;
              }

              var decoded = jsonDecode(cleanRaw);
              if (decoded is List)
                quizList = decoded;
              else if (decoded is Map && decoded.containsKey('quizzes'))
                quizList = decoded['quizzes'];
            } catch (e) {
              print('Lỗi parse quizzes string: $e');
            }
          } else if (rawQuizzes is List) {
            quizList = rawQuizzes;
          } else if (rawQuizzes is Map && rawQuizzes.containsKey('quizzes')) {
            quizList = rawQuizzes['quizzes'];
          }

          for (var quiz in quizList) {
            if (quiz is Map) {
              String rawCorrectOption =
                  quiz['correct_option']?.toString().toLowerCase() ?? 'a';
              String formattedOption = 'A';

              if (rawCorrectOption.contains('b'))
                formattedOption = 'B';
              else if (rawCorrectOption.contains('c'))
                formattedOption = 'C';
              else if (rawCorrectOption.contains('d'))
                formattedOption = 'D';

              await txn.insert('Quiz', {
                'question_content':
                    quiz['question_content']?.toString() ?? 'Câu hỏi trống',
                'option_a': quiz['option_a']?.toString() ?? '',
                'option_b': quiz['option_b']?.toString() ?? '',
                'option_c': quiz['option_c']?.toString() ?? '',
                'option_d': quiz['option_d']?.toString() ?? '',
                'correct_option': formattedOption,
                'created_at': now,
                'document_id': docId,
              });
            }
          }
        }

        print(
          "🚀 [SQLITE SYNC] Đã rải phẳng toàn bộ học liệu của Document ID $docId xuống máy thành công!",
        );
        return true;
      } catch (e) {
        print("❌ Lỗi xảy ra trong tiến trình bóc tách đồng bộ dữ liệu: $e");
        return false;
      }
    });
  }
}
