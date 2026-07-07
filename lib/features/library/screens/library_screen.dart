import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flashcard/features/documents/screens/document_summary_screen.dart';
import 'package:flashcard/features/library/controllers/library_controller.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Map<String, dynamic>>> _loadDocumentsTask;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  void _refreshDocuments() {
    setState(() {
      _loadDocumentsTask = LibraryController.fetchAllDocuments();
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'Thư viện tài liệu',
        style: GoogleFonts.quicksand(
          color: const Color(0xFF1C648E),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFFE2E2E5);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tài liệu, môn học...',
          hintStyle: GoogleFonts.quicksand(color: const Color(0xFF71787F)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1C648E)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> docMap, BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFFE2E2E5);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1C1E);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF41484E);

    final subjectName = docMap['subject_name'] ?? 'Không rõ';
    final docName = docMap['folder_name'] ?? 'Tài liệu không tên';
    final createdAt = docMap['created_at'] ?? '';
    final dateDisplay = createdAt.length > 10
        ? createdAt.substring(0, 10)
        : createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.02,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final document = DocumentModel.fromMap(docMap);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentSummaryScreen(document: document),
              ),
            ).then((_) {
              _refreshDocuments();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C648E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF1C648E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subjectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ngày tạo: $dateDisplay',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: const Color(0xFF71787F),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF1C648E)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadDocumentsTask,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1C648E)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Đã xảy ra lỗi: ${snapshot.error}',
                style: GoogleFonts.quicksand(color: Colors.red),
              ),
            );
          }

          final allDocs = snapshot.data ?? [];
          final filteredDocs = allDocs.where((doc) {
            final docName = (doc['folder_name'] ?? '').toString().toLowerCase();
            final subName = (doc['subject_name'] ?? '')
                .toString()
                .toLowerCase();
            final query = _searchQuery.toLowerCase();
            return docName.contains(query) || subName.contains(query);
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 16),

                Text(
                  'Tất cả tài liệu (${filteredDocs.length})',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        const Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 16),

                if (filteredDocs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có tài liệu nào.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      return _buildDocumentCard(filteredDocs[index], context);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
