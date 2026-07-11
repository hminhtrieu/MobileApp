import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizController {
  final int documentId;

  List<Map<String, dynamic>> quizQuestions = [];
  int currentIndex = 0;
  bool isLoading = true;

  // Trạng thái làm bài
  String selectedOption = '';
  int correctCount = 0;
  List<Map<String, dynamic>> wrongQuestionsList =
      []; // Lưu danh sách các câu làm sai
  bool isQuizFinished = false;

  // Cấu hình Bộ đếm thời gian
  Timer? _timer;
  int remainingSeconds =
      15 * 60; // Mặc định 14:59 (15 phút) như file HTML của em

  QuizController({required this.documentId});

  // 1. Khởi chạy nạp data từ SQLite
  Future<void> loadQuizData(VoidCallback onUpdate) async {
    try {
      isLoading = true;
      onUpdate();

      quizQuestions = await QuizModel.dbGetQuizzesByDocument(documentId);

      isLoading = false;
      startTimer(onUpdate);
      onUpdate();
    } catch (e) {
      print('❌ Lỗi Controller khi nạp ngân hàng Quiz: $e');
      isLoading = false;
      onUpdate();
    }
  }

  // 2. Vận hành luồng đếm ngược thời gian làm bài
  void startTimer(VoidCallback onUpdate) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onUpdate();
      } else {
        _timer?.cancel();
        isQuizFinished = true; // Hết giờ, tự động ép kết thúc bài thi
        onUpdate();
      }
    });
  }

  // 3. Xử lý khi chọn đáp án (A, B, C, D)
  void selectOption(String option, VoidCallback onUpdate) {
    selectedOption = option;
    onUpdate();
  }

  // 4. Logic chuyển sang câu tiếp theo hoặc kết thúc bài thi
  void nextQuestion(VoidCallback onUpdate) {
    // 1. Chấm điểm câu hiện tại
    final currentQuestion = quizQuestions[currentIndex];
    String correctOption = currentQuestion['correct_option'] ?? '';

    if (selectedOption == correctOption) {
      correctCount++;
    } else {
      // Nếu làm sai, lưu lại câu hỏi kèm số thứ tự hiển thị để render ra bảng kết quả
      wrongQuestionsList.add({
        'index': currentIndex + 1,
        'content': currentQuestion['question_content'] ?? 'Trống',
      });
    }

    // 2. Chuyển sang câu tiếp theo
    if (currentIndex < quizQuestions.length - 1) {
      currentIndex++;
      selectedOption = ''; // Reset trạng thái chọn cho câu hỏi mới
    } else {
      _timer?.cancel();
      isQuizFinished = true; // Hoàn thành câu cuối cùng, bật Overlay kết quả
      _saveQuizResult();
    }
    onUpdate();
  }

  // 6. Lưu kết quả vào CSDL
  Future<void> _saveQuizResult() async {
    try {
      await QuizModel.dbSaveQuizResult(documentId, correctCount, quizQuestions.length);
      print('✅ Đã lưu kết quả bài Quiz: ${quizQuestions.length} câu');
    } catch (e) {
      print('❌ Lỗi khi lưu kết quả bài Quiz: $e');
    }
  }

  // 5. Tính toán các chỉ số đầu ra
  double get progressPercent {
    if (quizQuestions.isEmpty) return 0.0;
    return (currentIndex + 1) / quizQuestions.length;
  }

  int get scorePercentage {
    if (quizQuestions.isEmpty) return 0;
    return ((correctCount / quizQuestions.length) * 100).toInt();
  }

  String get formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _timer?.cancel();
  }
}
