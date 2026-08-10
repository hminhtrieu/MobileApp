import 'package:flashcard/features/documents/controllers/document_list_controller.dart';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flashcard/features/documents/screens/document_summary_screen.dart';
import 'package:flashcard/features/documents/screens/add_document.dart';
import 'package:flashcard/features/flashcard/screens/flashcard_screen.dart';
import 'package:flashcard/features/quiz/screens/quiz_screen.dart';
import 'package:flashcard/core/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentListScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  DocumentListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late final DocumentListController _controller;

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
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (_controller.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang nạp danh sách chủ đề...',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_controller.errorMessage != null) {
                    return Center(child: Text(_controller.errorMessage!));
                  }

                  final documentList = _controller.documents;

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      children: [
                        if (documentList.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có chủ đề nào trong môn học này. Hãy thêm mới!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildThemeCardList(documentList),
                        SizedBox(height: 20),
                        _buildAddThemeButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: (isDark ? Color(0xFF121212) : Color(0xFFF9F9FC)),
      elevation: 0.5,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Môn học: ${widget.subjectName}',
        style: TextStyle(
          color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildThemeCardList(List<DocumentModel> documentList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: documentList.length,
      itemBuilder: (context, index) {
        return _buildThemeCard(documentList[index], index + 1);
      },
    );
  }

  Widget _buildThemeCard(DocumentModel doc, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey[850]! : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.grey[700]! : Color(0xFFE2E2E5)), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)).withValues(alpha: 0.6),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                  color: Color.fromARGB(255, 172, 226, 249),
                  border: Border.all(color: (isDark ? Colors.grey[850]! : Colors.white)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  doc.getRandomDocumentIcon(),
                  color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E)),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Chủ đề: ${doc.folderName.replaceAll(RegExp(r'Chủ đề \d+: '), '')}',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,

                    color: (isDark ? Colors.white : Color(0xFF1A1C1E)),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: (isDark ? Colors.grey[400]! : Color(0xFF71787f))),
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditDialog(doc);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(doc);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
                        SizedBox(width: 8),
                        Text('Đổi tên chủ đề'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa chủ đề', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[800]! : Color(0xFFF3F3F6)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Tệp: ${doc.fileName}',
              style: GoogleFonts.quicksand(fontSize: 14, color: (isDark ? Colors.grey[300]! : Colors.black87)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildChunkyButton('HỌC TẬP GHI NHỚ', Icons.style, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardLearnScreen(
                        documentId: doc.documentId!,
                        folderName: doc.folderName,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildChunkyButton(
                  'BÀI TẬP TRẮC NGHIỆM',
                  Icons.quiz,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          documentId: doc.documentId!,
                          folderName: doc.folderName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddThemeButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
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
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          border: Border.all(color: (isDark ? Colors.grey[700]! : Color(0xFFC0C7CF)), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)), size: 18),
            SizedBox(width: 8),
            Text(
              'THÊM CHỦ ĐỀ MỚI',
              style: GoogleFonts.quicksand(
                color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
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
      icon: Icon(icon, size: 16, color: (isDark ? Colors.blue[100]! : Color(0xFF004B70))),
      label: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: (isDark ? Colors.grey[300]! : Color(0xFF41484E)),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: (isDark ? Color(0xFF1E3A5F) : Color(0xFFCAE6FF)),
        foregroundColor: (isDark ? Colors.blue[100]! : Color(0xFF004B70)),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: (isDark ? Colors.grey[850]! : Colors.white)),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLoadingWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    return AlertDialog(
      backgroundColor: (isDark ? Colors.grey[850]! : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: (isDark ? Color(0xFF90CAF9) : Color(0xFF1C648E))),
          SizedBox(height: 16),
          Text(
            'Đang tải lên và xử lý dữ liệu với AI...\nQuá trình này có thể mất vài phút.',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        backgroundColor: (isDark ? Color(0xFFEF9A9A) : Color(0xFFBA1A1A)),
      ),
    );
  }

  void _showEditDialog(DocumentModel doc) {
    final TextEditingController textController = TextEditingController(
      text: doc.folderName.replaceAll(RegExp(r'Chủ đề \d+: '), ''),
    );
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Đổi tên chủ đề',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: 'Nhập tên mới'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _controller.renameDocument(
                    doc.documentId!,
                    textController.text,
                  );
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    _showErrorSnackBar(e.toString());
                  }
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(DocumentModel doc) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Xóa chủ đề',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${doc.folderName.replaceAll(RegExp(r'Chủ đề \d+: '), '')}"? Hành động này sẽ xóa vĩnh viễn toàn bộ Flashcard và Quiz bên trong!',
            style: GoogleFonts.quicksand(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await _controller.deleteDocument(doc.documentId!);
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    _showErrorSnackBar(e.toString());
                  }
                }
              },
              child: Text('Xóa', style: TextStyle(color: (isDark ? Colors.grey[850]! : Colors.white))),
            ),
          ],
        );
      },
    );
  }

  // Removed _buildBottomNavigationBar
}
