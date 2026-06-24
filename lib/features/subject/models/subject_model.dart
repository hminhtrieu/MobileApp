import 'package:flutter/material.dart';

class SubjectModel {
  final int? subjectId;
  final String subjectName;
  final String createdAt;

  SubjectModel({
    this.subjectId,
    required this.subjectName,
    required this.createdAt,
  });

  static List<SubjectModel> getMockSubjects() {
    return [
      SubjectModel(
        subjectId: 1,
        subjectName: 'Lập trình Flutter',
        createdAt: '2026-06-22',
      ),
      SubjectModel(
        subjectId: 2,
        subjectName: 'Tiếng Anh TOEIC',
        createdAt: '2026-06-22',
      ),
      SubjectModel(
        subjectId: 3,
        subjectName: 'Hệ quản trị CSDL',
        createdAt: '2026-06-22',
      ),
    ];
  }

  IconData getRandomSubjectIcon() {
    final List<IconData> iconPool = [
      Icons.auto_stories,
      Icons.wb_incandescent,
      Icons.palette,
      Icons.rocket_launch,
      Icons.biotech,
      Icons.calculate,
      Icons.extension,
      Icons.emoji_objects,
      Icons.hourglass_top,
    ];

    if (subjectId == null) return iconPool[0];

    return iconPool[subjectId! % iconPool.length];
  }
}
