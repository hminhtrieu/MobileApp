import 'package:sqflite/sqflite.dart';
import 'package:flashcard/core/database/database_helper.dart';

class StatisticsModel {
  static Future<Map<String, dynamic>> dbFetchStatistics({int? subjectId}) async {
    final db = await DatabaseHelper.instance.database;

    String docWhere = subjectId != null ? 'WHERE subject_id = $subjectId' : '';
    String joinWhere = subjectId != null ? 'JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId' : '';

    // Total counts
    int totalDocuments = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Document $docWhere')) ?? 0;
    int totalFlashcards = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Flashcard t $joinWhere')) ?? 0;
    int totalQuizzes = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Quiz t $joinWhere')) ?? 0;

    // Flashcard memory levels
    String memoryQuery = subjectId != null 
        ? 'SELECT t.memory_level AS memory_level, COUNT(*) as count FROM Flashcard t JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId GROUP BY t.memory_level'
        : 'SELECT memory_level AS memory_level, COUNT(*) as count FROM Flashcard GROUP BY memory_level';
    
    final memoryRows = await db.rawQuery(memoryQuery);
    int hardCards = 0; // Chưa thuộc (1, 2, 3)
    int easyCards = 0; // Đã thuộc (0)
    for (var row in memoryRows) {
      int level = int.tryParse(row['memory_level'].toString()) ?? 1;
      int count = int.tryParse(row['count'].toString()) ?? 0;
      if (level == 0) {
        easyCards += count;
      } else {
        hardCards += count;
      }
    }

    // 3. Quiz average score
    String resultQuery = subjectId != null
        ? 'SELECT AVG(t.score) as avg_score, COUNT(*) as total_attempts, SUM(t.correct_answers) as sum_correct, SUM(t.total_questions) as sum_total FROM Result t JOIN Document d ON t.document_id = d.document_id WHERE d.subject_id = $subjectId'
        : 'SELECT AVG(score) as avg_score, COUNT(*) as total_attempts, SUM(correct_answers) as sum_correct, SUM(total_questions) as sum_total FROM Result';
        
    final result = await db.rawQuery(resultQuery);
    double averageScore = 0.0;
    int totalAttempts = 0;
    int sumCorrect = 0;
    int sumTotal = 0;
    
    if (result.isNotEmpty) {
      averageScore = (result.first['avg_score'] as num?)?.toDouble() ?? 0.0;
      totalAttempts = (result.first['total_attempts'] as int?) ?? 0;
      sumCorrect = (result.first['sum_correct'] as int?) ?? 0;
      sumTotal = (result.first['sum_total'] as int?) ?? 0;
    }

    String debugRows = memoryRows.toString();

    return {
      'debugRows': debugRows,
      'totalDocuments': totalDocuments,
      'totalFlashcards': totalFlashcards,
      'totalQuizzes': totalQuizzes,
      'hardCards': hardCards,
      'easyCards': easyCards,
      'averageScore': averageScore,
      'totalAttempts': totalAttempts,
      'sumCorrect': sumCorrect,
      'sumTotal': sumTotal,
    };
  }
}
