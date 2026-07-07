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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF1C648E),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang nạp danh sách chủ đề...',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF41484E),
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      children: [
                        if (documentList.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
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
                        const SizedBox(height: 20),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF71787f)),
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditDialog(doc);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(doc);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Color(0xFF1C648E)),
                        SizedBox(width: 8),
                        Text('Đổi tên chủ đề'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
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
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: _buildChunkyButton(
              'TẢI THÊM TÀI LIỆU',
              Icons.upload_file,
              () async {
                try {
                  await _controller.uploadAdditionalDocument(doc);
                } catch (e) {
                  String error = e.toString();
                  if (error.startsWith('START_UPLOAD:')) {
                    final parts = error
                        .replaceAll('START_UPLOAD:', '')
                        .split('|');
                    if (parts.length == 2) {
                      final filePath = parts[0];
                      final fileName = parts[1];

                      _showLoadingDialog();
                      try {
                        await _controller.processAdditionalUpload(
                          doc,
                          filePath,
                          fileName,
                        );
                        if (mounted) {
                          Navigator.pop(context); // Đóng Loading Dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tải thêm tài liệu thành công!',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (uploadError) {
                        if (mounted) {
                          Navigator.pop(context); // Đóng Loading Dialog
                          _showErrorSnackBar(uploadError.toString());
                        }
                      }
                    }
                  } else {
                    _showErrorSnackBar(error);
                  }
                }
              },
            ),
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLoadingWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF1C648E)),
          const SizedBox(height: 16),
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
        backgroundColor: const Color(0xFFBA1A1A),
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
            decoration: const InputDecoration(hintText: 'Nhập tên mới'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
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
              child: const Text('Lưu'),
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
              child: const Text('Hủy'),
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
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Removed _buildBottomNavigationBar
}
