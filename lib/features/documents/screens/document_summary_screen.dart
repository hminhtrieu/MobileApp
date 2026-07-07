import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flashcard/features/flashcard/screens/flashcard_screen.dart';
import 'package:flashcard/features/quiz/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentSummaryScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentSummaryScreen({super.key, required this.document});

  @override
  State<DocumentSummaryScreen> createState() => _DocumentSummaryScreenState();
}

class _DocumentSummaryScreenState extends State<DocumentSummaryScreen> {
  String _selectedFileToView = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // 🌟 ĐÃ BỎ: _buildSectionTabs() (Thanh chọn 3 nút cũ đã được xóa bỏ hoàn toàn ở đây)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
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
                      const SizedBox(height: 20),
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
      backgroundColor: const Color(0xFFF9F9FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1C648E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tóm tắt tài liệu',
        style: GoogleFonts.quicksand(
          color: const Color(0xFF1C648E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    // Nếu trong file document_model.dart của em trường tên file là khác, em nhớ sửa lại chữ .fileName tương ứng nhé!
    final List<String> textFiles = [
      widget.document.fileName,
      'Tom_tat_bai_giang_bo_sung.pdf',
    ];
    if (_selectedFileToView.isEmpty) {
      _selectedFileToView = textFiles.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCAE6FF),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF1C648E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.document.folderName, // Đổ tên chủ đề động
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001E30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white54, thickness: 1),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFileToView,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF1C648E),
                ),
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: const Color(0xFF41484E),
                  fontWeight: FontWeight.bold,
                ),
                items: textFiles.map((String file) {
                  return DropdownMenuItem<String>(
                    value: file,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Color(0xFFBA1A1A),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(file, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFileToView = newValue;
                      print('Đang chuyển sang xem tóm tắt của file: $newValue');
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E2E5), width: 1),
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
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF3F3F6), thickness: 1.5),
          const SizedBox(height: 14),

          // 🌟 HIỂN THỊ CHUỖI VĂN BẢN ĐỘNG TUẦN TỰ:
          // Toàn bộ text dài do n8n sinh ra sẽ được hiển thị đầy đủ tại đây.
          // Triệu lưu ý: Nếu trong file 'document_model.dart' của em trường này không phải tên là '.summary'
          // mà tên là '.content' thì em đổi chữ '.summary' dưới đây thành '.content' nhé!
          Text(
            widget.document.summaryContext,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF41484E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Khối box mẹo nhỏ màu vàng giữ nguyên UI theo file gốc
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDF96).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: Color(0xFF765B06), width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Thuật ngữ quan trọng:',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF594400),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hãy chú ý ghi nhớ mốc sự kiện chính và các khái niệm cơ bản xuất hiện trong đoạn văn trên, đây là phần rất dễ xuất hiện trong các bài trắc nghiệm ôn tập!',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    height: 1.5,
                    color: const Color(0xFF594400),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E2E5), width: 1),
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
                  icon: const Icon(
                    Icons.style,
                    size: 18,
                    color: Color(0xFF004B70),
                  ),
                  label: Text(
                    'Luyện Flashcard',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF004B70),
                    side: const BorderSide(
                      color: Color(0xFFCAE6FF),
                      width: 1.5,
                    ),
                    backgroundColor: const Color(
                      0xFFCAE6FF,
                    ).withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  icon: const Icon(Icons.quiz, size: 18, color: Colors.white),
                  label: Text(
                    'Làm Trắc nghiệm',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1C648E),
                    foregroundColor: Colors.white,
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
