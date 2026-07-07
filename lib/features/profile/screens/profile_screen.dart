import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcard/main.dart'; // Import themeNotifier

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1C1E);
    final cardColor = Theme.of(context).cardColor;
    final borderColor = isDarkMode ? Colors.grey[800]! : const Color(0xFFE2E2E5);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Hồ sơ cá nhân',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1C648E).withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF1C648E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C648E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Học viên chăm chỉ',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Người dùng miễn phí',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: const Color(0xFF71787F),
              ),
            ),
            const SizedBox(height: 40),
            
            _buildSettingItem(
              Icons.dark_mode,
              'Giao diện tối',
              cardColor: cardColor,
              borderColor: borderColor,
              color: textColor,
              trailing: Switch(
                value: themeNotifier.value == ThemeMode.dark,
                activeColor: const Color(0xFF1C648E),
                onChanged: (v) {
                  themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            _buildSettingItem(
              Icons.notifications,
              'Thông báo nhắc học',
              cardColor: cardColor,
              borderColor: borderColor,
              color: textColor,
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF1C648E),
                onChanged: (v) {
                  setState(() {
                    _notificationsEnabled = v;
                  });
                },
              ),
            ),
            _buildSettingItem(Icons.cloud_download, 'Sao lưu dữ liệu', cardColor: cardColor, borderColor: borderColor, color: textColor),
            _buildSettingItem(Icons.info, 'Về ứng dụng', cardColor: cardColor, borderColor: borderColor, color: textColor),
            const SizedBox(height: 20),
            
            _buildSettingItem(Icons.delete_forever, 'Xóa toàn bộ dữ liệu', color: Colors.red, cardColor: cardColor, borderColor: borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {Widget? trailing, required Color color, required Color cardColor, required Color borderColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 16,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {},
        ),
      ),
    );
  }
}
