import 'package:sqflite/sqflite.dart';
import 'package:flashcard/core/database/database_helper.dart';

class QuizModel {
  final int? questionId;
  final String questionContent;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String createdAt;
  final int documentId;

  QuizModel({
    this.questionId,
    required this.questionContent,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.createdAt,
    required this.documentId,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      questionId: map['question_id'] as int?,
      questionContent: map['question_content'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      optionD: map['option_d'] as String,
      correctOption: map['correct_option'] as String,
      createdAt: map['created_at'] as String,
      documentId: map['document_id'] as int,
    );
  }

  static Future<List<Map<String, dynamic>>> dbGetQuizzesByDocument(int documentId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'Quiz',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'question_id ASC',
    );
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<void> dbSaveResult(int documentId, int correctCount, int totalQuestions) async {
    final db = await DatabaseHelper.instance.database;
    
    
    final attemptQuery = await db.rawQuery('SELECT COUNT(*) as count FROM Result WHERE document_id = ?', [documentId]);
    int attemptNumber = (Sqflite.firstIntValue(attemptQuery) ?? 0) + 1;

    
    double score = (correctCount / totalQuestions) * 10;

    await db.insert('Result', {
      'correct_answers': correctCount,
      'total_questions': totalQuestions,
      'score': score,
      'attempt_number': attemptNumber,
      'created_at': DateTime.now().toIso8601String(),
      'document_id': documentId,
    });
  }
}
