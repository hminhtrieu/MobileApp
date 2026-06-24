import 'package:flashcard/features/documents/screens/document_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/subject_model.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  // Lấy dữ liệu ảo đã tạo ở lớp Model để đưa vào danh sách hiển thị
  List<SubjectModel> subjects = SubjectModel.getMockSubjects();

  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),

      //top nav
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 24),

            _buildSubjectList(),
            const SizedBox(height: 16),
          ],
        ),
      ),

      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const Icon(Icons.arrow_back, color: Color(0xFF1C648E)),
      title: const Text(
        'Không gian học tập',
        style: TextStyle(
          color: Color(0xFF1C648E),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1C648E)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chào mừng trở lại! Cùng khám phá những kiến thức thú vị hôm nay nào.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),

        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.school, color: Color(0xFF1C648E), size: 20),
            const SizedBox(width: 8),
            Text(
              'Bạn đang có ${subjects.length} môn học',
              style: const TextStyle(color: Color(0xFF41484E), fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleStatItem(
    String title,
    String value,
    IconData icon,
    Color bgcolor,
    Color textColor,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final item = subjects[index];
        return _buildSubjectCard(item, context);
      },
    );
  }

  Widget _buildSubjectCard(SubjectModel subject, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E2E5), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DocumentListScreen(subjectName: subject.subjectName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFCAE6FF),
                      child: Icon(
                        subject.getRandomSubjectIcon(),
                        color: Color(0xFF1C648E),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.subjectName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ngày tạo: ${subject.createdAt}',
                            style: const TextStyle(
                              color: Color(0xFF71787F),
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

  Widget _buildBottomNav() {
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
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  subjects.add(
                    SubjectModel(
                      subjectId: subjects.length + 1,
                      subjectName: nameController.text,
                      createdAt: '2026-06-23',
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm ngay'),
          ),
        ],
      ),
    );
  }
}
