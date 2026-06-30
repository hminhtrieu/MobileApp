import 'dart:convert';
import 'package:flashcard/features/documents/model/document_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart'; // Thư viện chính chủ xử lý chọn file
import 'package:flashcard/core/database/sync_controller.dart';
// Đảm bảo import đúng model Document của em

class AddThemeScreen extends StatefulWidget {
  final String subjectName;
  final int subjectId; // Nhận ID môn học cha để liên kết Khóa ngoại khi lưu DB

  const AddThemeScreen({
    super.key,
    required this.subjectName,
    required this.subjectId,
  });

  @override
  State<AddThemeScreen> createState() => _AddThemeScreenState();
}

class _AddThemeScreenState extends State<AddThemeScreen> {
  final TextEditingController _themeNameController = TextEditingController();
  final SyncController _syncController = SyncController();

  // 🌟 Biến lưu trữ thông tin File thật được chọn từ thiết bị (Chuẩn XFile)
  XFile? _pickedFile;
  int _fileLengthInBytes =
      0; // 🚀 BIẾN CỤC BỘ: Lưu trữ dung lượng file thật sau khi đọc bất đồng bộ
  bool _isLoading = false;

  @override
  void dispose() {
    _themeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickRealFile() async {
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'documents',
        extensions: <String>['pdf', 'doc', 'docx', 'txt'],
      );

      // Gọi trình mở file hệ thống của Flutter Team
      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file != null) {
        // 🚀 TỐI ƯU LOGIC: Đọc dung lượng file thật bất đồng bộ để tránh nghẽn luồng UI
        final int length = await file.length();
        setState(() {
          _pickedFile = file;
          _fileLengthInBytes = length; // Cập nhật dung lượng thực tế
        });
      }
    } catch (e) {
      _showErrorSnackBar('Không thể mở trình chọn file của thiết bị: $e');
    }
  }

  // 🚀 PIPELINE THẬT: Bắn File vật lý lên n8n -> Hứng JSON -> Ghi SQLite
  Future<void> _uploadAndProcessDocument() async {
    if (_pickedFile == null || _pickedFile!.path.isEmpty) {
      _showErrorSnackBar('Vui lòng chọn một tệp tài liệu học tập thật!');
      return;
    }

    final String themeName = _themeNameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    try {
      // 1. TỐI ƯU HẠ TẦNG: Tạo bản ghi vật lý đại diện xuống DB trước để lấy rowId tự tăng chuẩn xác từ SQLite
      final newDoc = DocumentModel(
        folderName: themeName,
        fileName: _pickedFile!.name,
        filePath: _pickedFile!.path,
        summaryContext: 'Đang chờ n8n AI phân tích...',
        createdAt: DateTime.now().toIso8601String(),
        subjectId: widget.subjectId,
      );

      // Chèn ngầm và thu về ID chính xác của SQLite
      int targetDocId = await DocumentModel.dbInsertDocument(newDoc);

      // 2. THIẾT LẬP MULTIPART REQUEST ĐỂ GỬI FILE VẬT LÝ (SỬ DỤNG DIO ĐỂ TRÁNH LỖI SOCKET/TIMEOUT)
      final url = 'http://192.168.1.2:5678/webhook-test/upload-document';

      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 90);
      dio.options.receiveTimeout = const Duration(seconds: 90);

      FormData formData = FormData.fromMap({
        'document_id': targetDocId.toString(),
        'subject_id': widget.subjectId.toString(),
        'folder_name': themeName,
        'file': await MultipartFile.fromFile(
          _pickedFile!.path,
          filename: _pickedFile!.name,
        ),
      });

      // Gửi request lên n8n backend và đợi phản hồi
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        // Giải mã gói tin thô nhận từ n8n (Dio tự động parse Map nếu là JSON)
        final Map<String, dynamic> n8nRawResponse = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // 3. GỌI SYNC CONTROLLER: Giải mã double-decode và phân rã học liệu xuống 3 bảng SQLite
        bool isSyncSuccess = await _syncController.importN8nDataToDatabase(
          targetDocId,
          n8nRawResponse,
        );

        if (mounted) {
          Navigator.pop(context); // Đóng Loading Dialog

          if (isSyncSuccess) {
            // 4. TRẢ KẾT QUẢ THÀNH CÔNG VỀ TRANG CHA ĐỂ MỞ KHÓA 3 CHỨC NĂNG VỚI DATA THẬT
            Navigator.pop(context, true);
          } else {
            _showErrorSnackBar(
              'Lỗi phân rã cấu trúc JSON khi rải dữ liệu xuống CSDL cục bộ!',
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          _showErrorSnackBar(
            'Cổng n8n báo lỗi hệ thống: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Lỗi nghẽn mạch kết nối hoặc timeout luồng AI: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            'n8n AI đang tiến hành phân tích tệp thật,\ntóm tắt văn bản và kiến tạo học liệu...',
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
                _buildFileUploadArea(), // Khu vực tải file thật
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
          enabled: !_isLoading,
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
          onTap: _isLoading ? null : _pickRealFile,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _pickedFile != null ? _pickedFile!.name : 'Chọn tài liệu',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pickedFile != null
                      ? 'Dung lượng: ${(_fileLengthInBytes / 1024).toStringAsFixed(1)} KB - Nhấn để đổi'
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
            color: const Color(0xFF1C648E).withValues(alpha: 0.5),
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
          color: Colors.white.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E2E5), width: 1),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _uploadAndProcessDocument,
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
