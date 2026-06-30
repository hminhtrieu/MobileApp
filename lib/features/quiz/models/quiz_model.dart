
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
}
