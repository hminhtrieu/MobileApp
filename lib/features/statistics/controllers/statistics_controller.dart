import 'package:flashcard/features/subject/models/subject_model.dart';
import '../models/statistics_model.dart';

class StatisticsController {
  Future<List<SubjectModel>> getSubjects() async {
    return await SubjectModel.dbGetAllSubjects();
  }

  Future<Map<String, dynamic>> fetchStatistics({int? subjectId}) async {
    return await StatisticsModel.dbFetchStatistics(subjectId: subjectId);
  }
}
