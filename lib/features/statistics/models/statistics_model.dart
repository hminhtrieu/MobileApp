import 'package:sqflite/sqflite.dart';
import 'package:flashcard/core/database/database_helper.dart';

class StatisticsModel {
  static Future<Map<String, dynamic>> dbFetchStatistics({int? subjectId}) async {
    final db = await DatabaseHelper.instance.database;

    String docWhere = subjectId != null ? 'WHERE subject_id = $subjectId' : '';
    String joinWhere = subjectId != null ? 'JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId' : '';

    // 1. Total counts
    int totalDocuments = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Document $docWhere')) ?? 0;
    int totalFlashcards = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Flashcard t $joinWhere')) ?? 0;
    int totalQuizzes = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Quiz t $joinWhere')) ?? 0;

    // 2. Flashcard memory levels
    String memoryQuery = subjectId != null 
        ? 'SELECT t.memory_level, COUNT(*) as count FROM Flashcard t JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId GROUP BY t.memory_level'
        : 'SELECT memory_level, COUNT(*) as count FROM Flashcard GROUP BY memory_level';
    
    final memoryRows = await db.rawQuery(memoryQuery);
    int hardCards = 0; // level 1
    int mediumCards = 0; // level 2
    int easyCards = 0; // level 3
    for (var row in memoryRows) {
      if (row['memory_level'] == 1) hardCards = row['count'] as int;
      if (row['memory_level'] == 2) mediumCards = row['count'] as int;
      if (row['memory_level'] == 3) easyCards = row['count'] as int;
    }

    // 3. Quiz average score
    String quizResultQuery = subjectId != null
        ? 'SELECT AVG(t.score) as avg_score, COUNT(*) as total_attempts, SUM(t.correct_answers) as sum_correct, SUM(t.total_questions) as sum_total FROM Quiz_Result t JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId'
        : 'SELECT AVG(score) as avg_score, COUNT(*) as total_attempts, SUM(correct_answers) as sum_correct, SUM(total_questions) as sum_total FROM Quiz_Result';
        
    final quizResult = await db.rawQuery(quizResultQuery);
    double averageScore = 0.0;
    int totalAttempts = 0;
    int sumCorrect = 0;
    int sumTotal = 0;
    
    if (quizResult.isNotEmpty) {
      averageScore = (quizResult.first['avg_score'] as num?)?.toDouble() ?? 0.0;
      totalAttempts = (quizResult.first['total_attempts'] as int?) ?? 0;
      sumCorrect = (quizResult.first['sum_correct'] as int?) ?? 0;
      sumTotal = (quizResult.first['sum_total'] as int?) ?? 0;
    }

    return {
      'totalDocuments': totalDocuments,
      'totalFlashcards': totalFlashcards,
      'totalQuizzes': totalQuizzes,
      'hardCards': hardCards,
      'mediumCards': mediumCards,
      'easyCards': easyCards,
      'averageScore': averageScore,
      'totalAttempts': totalAttempts,
      'sumCorrect': sumCorrect,
      'sumTotal': sumTotal,
    };
  }
}
