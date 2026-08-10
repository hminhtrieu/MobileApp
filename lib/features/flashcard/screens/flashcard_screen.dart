import 'dart:math';
import 'package:flashcard/features/flashcard/controllers/flashcard_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardLearnScreen extends StatefulWidget {
  final int documentId;
  final String folderName;

  FlashcardLearnScreen({
    super.key,
    required this.documentId,
    required this.folderName,
  });

  @override
  State<FlashcardLearnScreen> createState() => _FlashcardLearnScreenState();
}

class _FlashcardLearnScreenState extends State<FlashcardLearnScreen>
    with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late FlashcardController _controller;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _controller = FlashcardController(documentId: widget.documentId);
    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _controller.loadFlashcards(() => setState(() {}));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleToggleCard() {
    setState(() {
      _controller.isFlipped = !_controller.isFlipped;
      if (_controller.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  void _refreshUIOnStateChange() {
    setState(() {
      if (!_controller.isFlipped && _flipController.value > 0) {
        _flipController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
        body: Center(
          child: CircularProgressIndicator(color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
        ),
      );
    }

    if (_controller.flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
        appBar: _buildAppBar(context),
        body: Center(
          child: Text(
            'Chưa có dữ liệu thẻ ghi nhớ!\nVui lòng n8n phân tách văn bản trước.',
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

    if (_controller.currentIndex >= _controller.flashcards.length) {
      return Scaffold(
        backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFB1EFD8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.done_all,
                  size: 64,
                  color: (isDark ? Color(0xFFA5D6A7) : Color(0xFF2C6956)),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Chúc mừng!\nBạn đã ôn tập xong chủ đề này.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: (isDark ? Color(0xFFA5D6A7) : Color(0xFF2C6956)),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text('Quay lại danh sách'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isDark ? Color(0xFFA5D6A7) : Color(0xFF2C6956)),
                  foregroundColor: (isDark ? Colors.grey[850]! : Colors.white),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _controller.flashcards[_controller.currentIndex];
    final int cardId = currentCard['card_id'];

    // 🌟 FIX LỖI "TRỐNG": Hoán đổi hoặc gán linh hoạt nếu font_text từ n8n đổ về bị rỗng
    String frontText = currentCard['front_text'] ?? '';
    String backText = currentCard['back_text'] ?? '';

    if (frontText.trim().isEmpty || frontText == 'Trống') {
      frontText =
          widget.folderName; // Lấy tạm tên chủ đề làm mặt trước nếu data trống
    }

    return Scaffold(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildFloatingBlob(
            top: 100,
            left: -60,
            color: Color(0xFF7CB9E8).withOpacity(0.35),
          ),
          _buildFloatingBlob(
            bottom: 180,
            right: -40,
            color: Color(0xFFAEEDD5).withOpacity(0.35),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(_controller.progressPercent),

                // 🎴 Khung Canvas chứa thẻ lật
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: GestureDetector(
                        onTap: _handleToggleCard,
                        child: AnimatedBuilder(
                          animation: _flipController,
                          builder: (context, child) {
                            final transformValue = _flipController.value * pi;
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(transformValue),
                              alignment: Alignment.center,
                              child: transformValue < pi / 2
                                  ? _buildCardFront(frontText)
                                  : Transform(
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: _buildCardBack(backText),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                _buildHintText(),
                _buildRatingActions(cardId),
                SizedBox(
                  height: 20,
                ), // Tạo khoảng cách đệm nhẹ dưới đáy thay vì BottomNav cũ
              ],
            ),
          ),
          // 🌟 ĐÃ BỎ: _buildBottomNavBar() hoàn toàn khỏi Stack để lấy diện tích cho khung nội dung
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.folderName,
        style: GoogleFonts.quicksand(
          color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildFloatingBlob({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildProgressIndicator(double percent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ: ${_controller.currentIndex + 1}/${_controller.flashcards.length} thẻ',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (isDark ? Color(0xFFA5D6A7) : Color(0xFF2C6956)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (percent * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF96D3BD),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (percent * 100).toInt(),
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 THẺ MẶT TRƯỚC (THUẬT NGỮ)
  Widget _buildCardFront(String term) {
    return Container(
      width: 340,
      height: 380, // Khóa chiều cao cố định cân đối cho form Canvas
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850]! : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF))),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)).withOpacity(0.15),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🌟 ICON THU NHỎ TRÊN ĐẦU THEO THIẾT KẾ MỚI
          Container(
            width: 44,
            height: 44, // Giảm kích thước từ 64 xuống 44
            decoration: BoxDecoration(
              color: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_edu,
              color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
              size: 24,
            ), // Thu nhỏ cỡ icon xuống 24
          ),
          SizedBox(height: 10),
          Text(
            'THUẬT NGỮ',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 14),

          // 🌟 BỌC SINGLECHILDSCROLLVIEW: Cho phép kéo cuộn văn bản nếu thuật ngữ quá dài
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(
                  term,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 THẺ MẶT SAU (ĐỊNH NGHĨA)
  Widget _buildCardBack(String definition) {
    return Container(
      width: 340,
      height: 380,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850]! : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFD0D4F1)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)).withOpacity(0.1),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🌟 ICON THU NHỎ TRÊN ĐẦU THEO THIẾT KẾ MỚI
          Container(
            width: 44,
            height: 44, // Giảm kích thước từ 64 xuống 44
            decoration: BoxDecoration(
              color: Color(0xFFE0E4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb,
              color: Color(0xFF3F4E93),
              size: 24,
            ), // Thu nhỏ cỡ icon xuống 24
          ),
          SizedBox(height: 10),
          Text(
            'ĐỊNH NGHĨA',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F4E93),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 14),

          // 🌟 FIX LỖI OVERFLOW: Cho phép kéo cuộn nội dung định nghĩa dài thoải mái mà không bị gạch sọc vàng đen hệ thống!
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                definition,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 16, color: (isDark ? Colors.grey[300]! : Color(0xFF41484E))),
          SizedBox(width: 6),
          Text(
            'Chạm để lật thẻ',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingActions(int cardId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildChunkyButton(
            label: 'Đã thuộc',
            icon: Icons.skip_next,
            bg: (isDark ? Color(0xFF303030) : Color(0xFFEBEBEB)),
            textCol: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
            borderCol: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)),
            level: 0,
            cardId: cardId,
          ),
          _buildChunkyButton(
            label: 'Khó',
            icon: Icons.sentiment_very_dissatisfied,
            bg: (isDark ? Color(0xFF4A1414) : Color(0xFFFFDAD6)),
            textCol: (isDark ? Color(0xFFFFB4AB) : Color(0xFF93000a)),
            borderCol: (isDark ? Color(0xFFFFB4AB) : Color(0xFFBA1A1A)),
            level: 1,
            cardId: cardId,
          ),
          _buildChunkyButton(
            label: 'Trung bình',
            icon: Icons.sentiment_neutral,
            bg: (isDark ? Color(0xFF574200) : Color(0xFFFFE0A3)),
            textCol: (isDark ? Color(0xFFFFE0A3) : Color(0xFF574200)),
            borderCol: (isDark ? Color(0xFFBCA046) : Color(0xFF765B06)),
            level: 2,
            cardId: cardId,
          ),
          _buildChunkyButton(
            label: 'Dễ',
            icon: Icons.sentiment_very_satisfied,
            bg: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
            textCol: (isDark ? Colors.white : Color(0xFF001E30)),
            borderCol: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
            level: 3,
            cardId: cardId,
          ),
        ],
      ),
    );
  }

  Widget _buildChunkyButton({
    required String label,
    required IconData icon,
    required Color bg,
    required Color textCol,
    required Color borderCol,
    required int level,
    required int cardId,
  }) {
    return ElevatedButton(
      onPressed: () {
        _controller.updateMemoryLevel(
          cardId,
          level,
          _refreshUIOnStateChange,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderCol, width: 2),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textCol, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textCol,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
