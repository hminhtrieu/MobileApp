import 'package:flutter/material.dart';

class DocumentModel {
  final int documentId;
  final String fileName;
  final String folderName;
  final String summaryContext;
  final String createdAt;

  DocumentModel({
    required this.documentId,
    required this.fileName,
    required this.folderName,
    required this.summaryContext,
    required this.createdAt,
  });

  static List<DocumentModel> getMockDocuments() {
    return [
      DocumentModel(
        documentId: 1,
        fileName: 'Tai_Lieu_On_Thi_Kỳ_1.pdf',
        folderName: 'Chương 1: Khái niệm cơ bản',
        summaryContext:
            'Bài viết tóm tắt toàn bộ các định nghĩa nền tảng, hệ tư tưởng cốt lõi và các mốc sự kiện quan trọng cần ghi nhớ...',
        createdAt: '24/06/2026',
      ),
    ];
  }

  IconData getRandomDocumentIcon() {
    final List<IconData> iconPool = [
      Icons.auto_stories, // Quyển sách
      Icons.wb_incandescent, // Bóng đèn
      Icons.palette, // Bảng màu
      Icons.rocket_launch, // Tên lửa
      Icons.biotech, // Kính hiển vi
      Icons.calculate, // Máy tính
      Icons.extension, // Mảnh ghép
      Icons.emoji_objects, // Ý tưởng
    ];

    // Dùng toán tử chia lấy dư dựa trên documentId của tài liệu
    return iconPool[documentId % iconPool.length];
  }
}
