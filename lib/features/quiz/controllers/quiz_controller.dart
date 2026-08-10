import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizController {
  final int documentId;

  List<Map<String, dynamic>> quizQuestions = [];
  int currentIndex = 0;
  bool isLoading = true;

  String selectedOption = '';
  int correctCount = 0;
  List<Map<String, dynamic>> wrongQuestionsList =
      []; // Lưu danh sách các câu làm sai
  bool isQuizFinished = false;

  // Bộ đếm thời gian
  Timer? _timer;
  int remainingSeconds =
      15 * 60; // Mặc định 14:59

  QuizController({required this.documentId});

  //Khởi chạy nạp data từ SQLite
  Future<void> ShuffleQuizData(VoidCallback onUpdate) async {
    try {
      isLoading = true;
      onUpdate();

      List<Map<String, dynamic>> rawQuestions = await QuizModel.dbGetQuizzesByDocument(documentId);
      
      // Tạo bản sao để có thể thay đổi dữ liệu (shuffle)
      quizQuestions = rawQuestions.map((q) => Map<String, dynamic>.from(q)).toList();
      
      // Xáo trộn thứ tự câu hỏi
      quizQuestions.shuffle();
      
      // Xáo trộn thứ tự 4 đáp án cho từng câu
      for (var q in quizQuestions) {
        String correctOpt = q['correct_option'] ?? 'A';
        String correctText = '';
        
        switch (correctOpt.toUpperCase()) {
          case 'A': correctText = q['option_a'] ?? ''; break;
          case 'B': correctText = q['option_b'] ?? ''; break;
          case 'C': correctText = q['option_c'] ?? ''; break;
          case 'D': correctText = q['option_d'] ?? ''; break;
        }
        
        List<String> options = [
          q['option_a'] ?? '',
          q['option_b'] ?? '',
          q['option_c'] ?? '',
          q['option_d'] ?? ''
        ];
        
        options.shuffle();
        
        q['option_a'] = options[0];
        q['option_b'] = options[1];
        q['option_c'] = options[2];
        q['option_d'] = options[3];
        
        if (options[0] == correctText) q['correct_option'] = 'A';
        else if (options[1] == correctText) q['correct_option'] = 'B';
        else if (options[2] == correctText) q['correct_option'] = 'C';
        else if (options[3] == correctText) q['correct_option'] = 'D';
      }

      isLoading = false;
      startTimer(onUpdate);
      onUpdate();
    } catch (e) {
      print('❌ Lỗi Controller khi nạp ngân hàng Quiz: $e');
      isLoading = false;
      onUpdate();
    }
  }

  //Vận hành luồng đếm ngược thời gian làm bài
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

  //Xử lý khi chọn đáp án (A, B, C, D)
  void selectOption(String option, VoidCallback onUpdate) {
    selectedOption = option;
    onUpdate();
  }

  // Logic chuyển sang câu tiếp theo hoặc kết thúc bài thi
  void nextQuestion(VoidCallback onUpdate) {
    final currentQuestion = quizQuestions[currentIndex];
    String correctOption = currentQuestion['correct_option'] ?? '';

    if (selectedOption == correctOption) {
      correctCount++;
    } else {
      wrongQuestionsList.add({
        'index': currentIndex + 1,
        'content': currentQuestion['question_content'] ?? 'Trống',
      });
    }

    // Chuyển sang câu tiếp theo
    if (currentIndex < quizQuestions.length - 1) {
      currentIndex++;
      selectedOption = '';
    } else {
      _timer?.cancel();
      isQuizFinished = true;
      _saveResult();
    }
    onUpdate();
  }

  //Lưu kết quả vào CSDL
  Future<void> _saveResult() async {
    try {
      await QuizModel.dbSaveResult(documentId, correctCount, quizQuestions.length);
      print('✅ Đã lưu kết quả bài Quiz: ${quizQuestions.length} câu');
    } catch (e) {
      print('❌ Lỗi khi lưu kết quả bài Quiz: $e');
    }
  }

  //Tính toán các chỉ số đầu ra
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
