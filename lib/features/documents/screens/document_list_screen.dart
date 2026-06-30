import 'package:flashcard/features/documents/controllers/document_list_controller.dart';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flashcard/features/documents/screens/document_summary_screen.dart';
import 'package:flashcard/features/documents/screens/add_document.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentListScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const DocumentListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late final DocumentListController _controller;
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = DocumentListController(widget.subjectId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (_controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  if (_controller.errorMessage != null) {
                    return Center(child: Text(_controller.errorMessage!));
                  }

                  final documentList = _controller.documents;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      children: [
                        if (documentList.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                'Chưa có chủ đề nào trong môn học này. Hãy thêm mới!',
                              ),
                            ),
                          )
                        else
                          _buildThemeCardList(documentList),
                        const SizedBox(height: 20),
                        _buildAddThemeButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9FC),
      elevation: 0.5,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1C648E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Môn học: ${widget.subjectName}',
        style: const TextStyle(
          color: Color(0xFF1C648E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildThemeCardList(List<DocumentModel> documentList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documentList.length,
      itemBuilder: (context, index) {
        return _buildThemeCard(documentList[index], index + 1);
      },
    );
  }

  Widget _buildThemeCard(DocumentModel doc, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E2E5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C648E).withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 172, 226, 249),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  doc.getRandomDocumentIcon(),
                  color: const Color(0xFF1C648E),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  doc.folderName.replaceAll(RegExp(r'Chủ đề \d+: '), ''),
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Tệp: ${doc.fileName}',
              style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildChunkyButton('HỌC TẬP GHI NHỚ', Icons.style, () {
                  print(
                    "Kích hoạt chuyển mạch học Flashcard của Doc ID: ${doc.documentId}",
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChunkyButton('BÀI TẬP TRẮC NGHIỆM', Icons.quiz, () {
                  print(
                    "Kích hoạt chuyển mạch làm Quiz của Doc ID: ${doc.documentId}",
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: _buildChunkyButton('TẢI TÀI LIỆU', Icons.upload_file, () {
              print("Đường dẫn tệp cục bộ: ${doc.filePath}");
            }),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildChunkyButton(
                  'XEM TÀI LIỆU TÓM TẮT',
                  Icons.psychology,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentSummaryScreen(document: doc),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildChunkyButton('SHARE TÀI LIỆU', Icons.share, () {
                  print(
                    "Kích hoạt luồng packAndShareFolder() cho Doc ID: ${doc.documentId}",
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddThemeButton() {
    return TextButton(
      onPressed: () async {
        final bool? isSyncDone = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddThemeScreen(
              subjectName: widget.subjectName,
              subjectId: widget.subjectId,
            ),
          ),
        );

        if (isSyncDone == true) {
          _controller.refreshDocuments();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, color: Color(0xFF41484E), size: 18),
          const SizedBox(width: 8),
          Text(
            'THÊM CHỦ ĐỀ MỚI',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF41484E),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChunkyButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: const Color(0xFF004B70)),
      label: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF41484E),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCAE6FF),
        foregroundColor: const Color(0xFF004B70),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1C648E),
      unselectedItemColor: const Color(0xFF41484E),
      onTap: (index) {
        setState(() {
          _currentBottomIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Thư viện',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
      ],
    );
  }
}
