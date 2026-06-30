import 'package:flashcard/features/documents/screens/document_list_screen.dart';
import 'package:flashcard/features/subject/controllers/subject_controller.dart';
import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectController _subjectController = SubjectController();
  late Future<List<SubjectModel>> _loadSubjectTask;

  int _currentBottomIndex = 0;

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
      backgroundColor: const Color(0xFFF9F9FC),

      //top nav
      appBar: _buildAppBar(),
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(subjectList.length),
                const SizedBox(height: 24),

                if (subjectList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Chưa có môn học nào. Hãy bấm [+] để thêm mới!',
                      ),
                    ),
                  )
                else
                  // 🛠️ FIX LOGIC ĐỔI TÊN BIẾN: Truyền nguyên mảng dữ liệu thật vào hàm
                  _buildSubjectList(subjectList),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
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

  // 🛠️ FIX LOGIC THAM SỐ: Khai báo nhận giá trị đếm số lượng môn thật
  Widget _buildHeroHeader(int totalSubjects) {
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
              // 🛠️ FIX LOGIC BIẾN: Sử dụng tham số totalSubjects thay cho biến ảo subjects cũ
              'Bạn đang có $totalSubjects môn học',
              style: const TextStyle(color: Color(0xFF41484E), fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildSubjectList(List<SubjectModel> subjectList) {
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
              builder: (context) => DocumentListScreen(
                subjectId: subject.subjectId!,
                subjectName: subject.subjectName,
              ),
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
                      backgroundColor: const Color(0xFFCAE6FF),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // Format lại chuỗi hiển thị ngày tạo từ CSDL thật
                            'Ngày tạo: ${subject.createdAt.length > 10 ? subject.createdAt.substring(0, 10) : subject.createdAt}',
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
