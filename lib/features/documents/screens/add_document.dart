import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddThemeScreen extends StatefulWidget {
  final String subjectName;

  const AddThemeScreen({super.key, required this.subjectName});

  @override
  State<AddThemeScreen> createState() => _AddThemeScreenState();
}

class _AddThemeScreenState extends State<AddThemeScreen> {
  final TextEditingController _themeNameController = TextEditingController();
  bool _isAutoSummary = true;
  bool _isAutoFlashcard = true;
  bool _isAutoQuiz = false;
  String? _selectedFileName;

  @override
  void dispose() {
    _themeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 12.0,
              bottom: 110.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 24),
                _buildThemeNameInput(),
                const SizedBox(height: 24),
                _buildFileUploadArea(),
                const SizedBox(height: 24),
                _buildAiAutomationSection(),
              ],
            ),
          ),
          _buildBottomActionButtonContainer(),
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
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Thêm chủ đề mới',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF1C648E),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            'Môn: ${widget.subjectName}',
            style: GoogleFonts.quicksand(
              color: const Color(0xFF71787F),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1594614271360-0ed9a570ae15?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildThemeNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Tên chủ đề',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
            ),
          ),
        ),
        TextField(
          controller: _themeNameController,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            color: const Color(0xFF1A1C1E),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Ví dụ: Lịch sử Việt Nam thế kỷ XX',
            hintStyle: GoogleFonts.quicksand(color: const Color(0xFF71787F)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(
                color: Color(0xFFC0C7CF),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(
                color: Color(0xFFC0C7CF),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(color: Color(0xFF1C648E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Tài liệu học tập của chủ đề',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _selectedFileName = 'Bai_Giang_Chuyen_De_Moi.pdf';
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC0C7CF), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCAE6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload,
                    color: Color(0xFF004B70),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedFileName ?? 'Chọn tài liệu',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedFileName != null
                      ? 'Nhấn để thay đổi tệp tin'
                      : 'Kéo thả hoặc nhấn để tải lên',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: const Color(0xFF71787F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiAutomationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E2E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C648E).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFAEEDD5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF316D5B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tự động hóa bằng AI',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3F3F6), thickness: 1.5),
          const SizedBox(height: 12),

          _buildAiFeatureItem(
            'Tự động tóm tắt nội dung chủ đề',
            Icons.description,
          ),
          const SizedBox(height: 14),
          _buildAiFeatureItem('Tự động sinh thẻ ghi nhớ', Icons.style),
          const SizedBox(height: 14),
          _buildAiFeatureItem('Tự động tạo câu hỏi trắc nghiệm', Icons.quiz),
        ],
      ),
    );
  }

  Widget _buildAiFeatureItem(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2C6956), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: const Color(0xFF1A1C1E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtonContainer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E2E5), width: 1),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: () {
              if (_themeNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vui lòng nhập tên chủ đề!',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFFBA1A1A),
                  ),
                );
                return;
              }

              Navigator.pop(context, _themeNameController.text.trim());
            },
            icon: const Icon(Icons.play_arrow, size: 20),
            label: Text(
              'Bắt đầu xử lý & Tạo chủ đề',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1C648E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
