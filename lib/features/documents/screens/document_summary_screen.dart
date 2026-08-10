import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flashcard/features/flashcard/screens/flashcard_screen.dart';
import 'package:flashcard/features/quiz/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentSummaryScreen extends StatefulWidget {
  final DocumentModel document;

  DocumentSummaryScreen({super.key, required this.document});

  @override
  State<DocumentSummaryScreen> createState() => _DocumentSummaryScreenState();
}

class _DocumentSummaryScreenState extends State<DocumentSummaryScreen> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  String _selectedFileToView = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // 🌟 ĐÃ BỎ: _buildSectionTabs() (Thanh chọn 3 nút cũ đã được xóa bỏ hoàn toàn ở đây)
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top:
                        16.0, // Tăng nhẹ khoảng cách top sau khi bỏ tab cho thoáng UI
                    bottom: 100.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      SizedBox(height: 20),
                      _buildSummaryContent(), // 🌟 Nội dung tóm tắt hiển thị trọn vẹn theo mạch văn bản
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tóm tắt tài liệu',
        style: GoogleFonts.quicksand(
          color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.grey[850]! : Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.document.folderName, // Đổ tên chủ đề động
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (isDark ? Colors.white : Color(0xFF001E30)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.white54, thickness: 1),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[850]! : Colors.white),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: (isDark ? Color(0xFFEF9A9A) : Color(0xFFBA1A1A)),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.document.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850]! : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDark ? Colors.grey[700]! : Color(0xFFE2E2E5)), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề cố định cho phân vùng nội dung chính
          Text(
            'Nội dung tóm tắt',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
            ),
          ),
          SizedBox(height: 14),
          Divider(color: (isDark ? Colors.grey[800]! : Color(0xFFF3F3F6)), thickness: 1.5),
          SizedBox(height: 14),

          // 🌟 HIỂN THỊ CHUỖI VĂN BẢN ĐỘNG TUẦN TỰ:
          // Toàn bộ text dài do n8n sinh ra sẽ được hiển thị đầy đủ tại đây.
          // Triệu lưu ý: Nếu trong file 'document_model.dart' của em trường này không phải tên là '.summary'
          // mà tên là '.content' thì em đổi chữ '.summary' dưới đây thành '.content' nhé!
          Text(
            widget.document.summaryContext,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.6,
              color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: (isDark ? Color(0xFF1E1E1E) : Colors.white).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: (isDark ? Colors.grey[700]! : Color(0xFFE2E2E5)), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardLearnScreen(
                          // Đảm bảo truyền đúng trường khóa chính của DocumentModel
                          // (Ví dụ: .documentId hoặc .id tùy theo model thật của em)
                          documentId: widget.document.documentId ?? 0,
                          folderName: widget
                              .document
                              .folderName, // Tên chủ đề để làm tiêu đề AppBar
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.style,
                    size: 18,
                    color: (isDark ? Colors.blue[100]! : Color(0xFF004B70)),
                  ),
                  label: Text(
                    'Luyện Flashcard',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: (isDark ? Colors.blue[100]! : Color(0xFF004B70)),
                    side: BorderSide(
                      color: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
                      width: 1.5,
                    ),
                    backgroundColor: Color(
                      0xFFCAE6FF,
                    ).withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          documentId:
                              widget.document.documentId ??
                              0, // Truyền ID để bốc đúng ngân hàng Quiz
                          folderName: widget
                              .document
                              .folderName, // Truyền tên chủ đề hiển thị tag
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.quiz, size: 18, color: (isDark ? Colors.grey[850]! : Colors.white)),
                  label: Text(
                    'Làm Trắc nghiệm',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                    foregroundColor: (isDark ? Colors.grey[850]! : Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
