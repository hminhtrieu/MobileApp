import 'package:flashcard/features/quiz/controllers/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final int documentId;
  final String folderName;

  QuizScreen({super.key, required this.documentId, required this.folderName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(documentId: widget.documentId);
    _controller.ShuffleQuizData(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
        body: Center(
          child: CircularProgressIndicator(
            color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
          ),
        ),
      );
    }

    if (_controller.quizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
        appBar: _buildSimpleAppBar(),
        body: Center(
          child: Text(
            'Chưa có dữ liệu bài tập trắc nghiệm!\nVui lòng đồng bộ hóa bằng AI trước.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _controller.quizQuestions[_controller.currentIndex];
    final String questionContent =
        currentQuestion['question_content'] ?? 'Trống';

    return Scaffold(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      appBar: _buildQuizHeader(),
      body: Stack(
        children: [
          // Background Blobs nhòe nghệ thuật
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFFFFDF96).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Color(0xFF7CB9E8).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Thẻ hiển thị câu hỏi
                          _buildQuestionCard(questionContent),
                          SizedBox(height: 24),

                          // 2. Danh sách 4 đáp án lựa chọn Chunky
                          _buildChunkyOptionButton(
                            'A',
                            currentQuestion['option_a'] ?? '',
                          ),
                          _buildChunkyOptionButton(
                            'B',
                            currentQuestion['option_b'] ?? '',
                          ),
                          _buildChunkyOptionButton(
                            'C',
                            currentQuestion['option_c'] ?? '',
                          ),
                          _buildChunkyOptionButton(
                            'D',
                            currentQuestion['option_d'] ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Khối nút điều hướng chuyển câu hỏi dưới đáy
                  _buildActionFooter(),
                ],
              ),
            ),
          ),

          // 🌟 MÀN HÌNH OVERLAY KẾT QUẢ KHI HOÀN THÀNH (Bọc hiệu ứng Glassmorphism)
          if (_controller.isQuizFinished) _buildResultsOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  PreferredSizeWidget _buildQuizHeader() {
    return AppBar(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Câu hỏi ${_controller.currentIndex + 1} / ${_controller.quizQuestions.length}',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.grey[400]! : Color(0xFF71787f)),
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: 120,
            height: 6,
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[850]! : Color(0xFFEDEEF1)),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (_controller.progressPercent * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? Color(0xFFA5D6A7) : Color(0xFF2C6956)),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (_controller.progressPercent * 100).toInt(),
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.0, top: 12.0, bottom: 12.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? Color(0xFF4A1414) : Color(0xFFFFDAD6)),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 14,
                  color: (isDark ? Color(0xFFFFB4AB) : Color(0xFF93000A)),
                ),
                SizedBox(width: 4),
                Text(
                  _controller.formattedTime,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (isDark ? Color(0xFFFFB4AB) : Color(0xFF93000A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850]! : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7CB9E8).withOpacity(0.15),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: Color(0xFF7CB9E8),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_edu,
                        size: 18,
                        color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.folderName.toUpperCase(),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  question,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChunkyOptionButton(String optionKey, String optionText) {
    final bool isSelected = _controller.selectedOption == optionKey;
    final bool hasSelectedAny = _controller.selectedOption.isNotEmpty;

    Color bg = (isDark ? Colors.grey[850]! : Colors.white);
    Color borderCol = (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF));
    Color textCol = (isDark ? Colors.white : Color(0xFF1A1C1E));

    if (isSelected) {
      bg = (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF));
      borderCol = (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E));
      textCol = (isDark ? Colors.blue[100]! : Color(0xFF004B70));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 14.0),
      child: ElevatedButton(
        onPressed: () =>
            _controller.selectOption(optionKey, () => setState(() {})),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          disabledBackgroundColor: bg,
          disabledForegroundColor: textCol,
          elevation: 0,
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderCol, width: 2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))
                    : Colors.transparent,
                border: Border.all(color: borderCol, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionKey,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? Colors.grey[850]! : Colors.white)
                        : (isDark ? Colors.grey[400]! : Color(0xFF71787f)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textCol,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionFooter() {
    final bool hasSelected = _controller.selectedOption.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 24.0, left: 20.0, right: 20.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: !hasSelected
                  ? null
                  : () => _controller.nextQuestion(() => setState(() {})),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelected
                    ? (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))
                    : (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)),
                foregroundColor: (isDark ? Colors.grey[850]! : Colors.white),
                disabledBackgroundColor: (isDark
                    ? Colors.grey[700]!
                    : Color(0xFFC0C7CF)),
                disabledForegroundColor: (isDark
                    ? Colors.grey[850]!
                    : Colors.white),
                elevation: hasSelected ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                  side: BorderSide(
                    color: hasSelected
                        ? (isDark ? Colors.blue[100]! : Color(0xFF004B70))
                        : (isDark ? Colors.grey[400]! : Color(0xFF71787f)),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Câu tiếp theo',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Chọn một đáp án để kích hoạt nút tiếp tục',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 MÀN HÌNH OVERLAY KẾT QUẢ KHI HOÀN THÀNH
  Widget _buildResultsOverlay() {
    return Positioned.fill(
      child: Container(
        color: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)).withOpacity(
          0.85,
        ),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[850]! : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Khối thông báo Chúc mừng trên đỉnh
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  color: Color(0xFFAEEDD5).withOpacity(0.5),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (isDark
                              ? Color(0xFFA5D6A7)
                              : Color(0xFF2C6956)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.celebration,
                          color: (isDark ? Colors.grey[850]! : Colors.white),
                          size: 36,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Hoàn thành!',
                        style: GoogleFonts.quicksand(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: (isDark
                              ? Color(0xFFC8E6C9)
                              : Color(0xFF002118)),
                        ),
                      ),
                      Text(
                        'Bạn đã làm rất tốt hôm nay.',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: (isDark
                              ? Color(0xFF81C784)
                              : Color(0xFF0D503F)),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Khối thống kê điểm số thật
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KẾT QUẢ',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (isDark
                                      ? Colors.grey[400]!
                                      : Color(0xFF71787f)),
                                ),
                              ),
                              Text(
                                '${_controller.correctCount} / ${_controller.quizQuestions.length} đúng',
                                style: GoogleFonts.quicksand(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: (isDark
                                      ? Color(0xFF90CAF9)
                                      : Color(0xFF1C648E)),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_controller.scorePercentage}%',
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: (isDark
                                  ? Color(0xFFA5D6A7)
                                  : Color(0xFF2C6956)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Progress bar kết quả bài làm
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (isDark
                              ? Colors.grey[850]!
                              : Color(0xFFEDEEF1)),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: _controller.scorePercentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (isDark
                                      ? Color(0xFFA5D6A7)
                                      : Color(0xFF2C6956)),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 100 - _controller.scorePercentage,
                              child: SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Hiển thị danh sách các câu làm sai cần coi lại
                      Text(
                        '⚠️ Cần xem lại (${_controller.wrongQuestionsList.length} câu):',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: (isDark
                              ? Color(0xFFFFB4AB)
                              : Color(0xFFBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 120,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _controller.wrongQuestionsList.length,
                          itemBuilder: (context, index) {
                            final item = _controller.wrongQuestionsList[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                '• Câu #${item['index']}: ${item['content']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: (isDark
                                      ? Colors.grey[300]!
                                      : Color(0xFF41484E)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16),
                      // Nút thoát quay về trang chủ
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: (isDark
                                ? Color(0xFF90CAF9)
                                : Color(0xFF1C648E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: Text(
                            'Quay lại tài liệu',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
