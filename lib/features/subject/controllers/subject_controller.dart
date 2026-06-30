import '../models/subject_model.dart';

class SubjectController {
  Future<List<SubjectModel>> fetchSubjectsList() async {
    try {
      return await SubjectModel.dbGetAllSubjects();
    } catch (e) {
      print("Lỗi hệ thống Controller khi nạp môn học: $e");
      return [];
    }
  }
}
