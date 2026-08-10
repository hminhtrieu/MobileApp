import 'package:flashcard/features/documents/screens/document_list_screen.dart';
import 'package:flashcard/features/subject/controllers/subject_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcard/core/widgets/custom_bottom_nav_bar.dart';
import '../models/subject_model.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectController _subjectController = SubjectController();
  late Future<List<SubjectModel>> _loadSubjectTask;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshSubject();
  }

  void _refreshSubject() {
    setState(() {
      _loadSubjectTask = _subjectController.fetchSubjectsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //top nav
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<SubjectModel>>(
        future:
            _loadSubjectTask, // Đón nhận luồng mảng thực thể từ SQLite nạp lên
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi hệ thống CSDL: ${snapshot.error}'));
          }

          final subjectList = snapshot.data ?? [];
          final filteredList = subjectList.where((subject) {
            return subject.subjectName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
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
                _buildHeroHeader(subjectList.length, context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 24),

                if (filteredList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
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
                            'Chưa có môn học nào. Hãy bấm [+] để thêm mới!',
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
                  _buildSubjectList(filteredList, context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),

      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'Không gian học tập',
        style: GoogleFonts.quicksand(
          color: const Color(0xFF1C648E),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroHeader(int totalSubjects, BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1C1E);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF41484E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại! \nChúc bạn một ngày tốt lành.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.school, color: Color(0xFF1C648E), size: 20),
            const SizedBox(width: 8),
            Text(
              'Bạn đang có $totalSubjects môn học',
              style: TextStyle(color: secondaryTextColor, fontSize: 15),
            ),
          ],
        ),
      ],
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
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm môn học...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF1C648E)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSubjectList(
    List<SubjectModel> subjectList,
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjectList.length,
      itemBuilder: (context, index) {
        final item = subjectList[index];
        return _buildSubjectCard(item, context);
      },
    );
  }

  Widget _buildSubjectCard(SubjectModel subject, BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFFE2E2E5);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1C1E);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF41484E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: Key(subject.subjectId.toString()),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.3,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text(
                        'Xác nhận xóa',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa môn học "${subject.subjectName}"? Mọi tài liệu bên trong cũng sẽ bị xóa vĩnh viễn.',
                        style: GoogleFonts.quicksand(),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              60,
                              21,
                              79,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (shouldDelete == true && subject.subjectId != null) {
                  await SubjectModel.dbDeleteSubject(subject.subjectId!);
                  _refreshSubject();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa môn học ${subject.subjectName}'),
                      ),
                    );
                  }
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, size: 28),
                  SizedBox(height: 4),
                  Text(
                    'Xóa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentListScreen(
                      subjectId: subject.subjectId!,
                      subjectName: subject.subjectName,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(
                              0xFF1C648E,
                            ).withValues(alpha: 0.1),
                            child: Icon(
                              // Giả định hàm này nằm trong file Model của em để lấy icon ngẫu nhiên
                              subject.getRandomSubjectIcon(),
                              color: const Color(0xFF1C648E),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.subjectName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  // Format lại chuỗi hiển thị ngày tạo từ CSDL thật
                                  'Ngày tạo: ${subject.createdAt.length > 10 ? subject.createdAt.substring(0, 10) : subject.createdAt}',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddSubjectDialog(context),
      backgroundColor: const Color(0xFF1C648E),
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  // _buildBottomNav removed

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thêm môn học mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Tên môn học',
            filled: true,
            fillColor: const Color(0xFFEDEEF1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFF1C648E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C648E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                // 🚀 FIX LUỒNG GHI DATA THẬT: Gọi hàm Model chèn trực tiếp xuống SQLite
                await SubjectModel.dbInsertSubject(nameController.text);

                if (context.mounted) {
                  Navigator.pop(context); // Đóng Dialog nhập liệu
                  _refreshSubject(); // Tự động re-render và nạp mới danh sách thật từ SQLite
                }
              }
            },
            child: const Text('Thêm ngay'),
          ),
        ],
      ),
    );
  }
}
