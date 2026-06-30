import 'package:flashcard/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SubjectModel {
  final int? subjectId;
  final String subjectName;
  final String createdAt;

  SubjectModel({
    this.subjectId,
    required this.subjectName,
    required this.createdAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      subjectId: map['subject_id'] as int?,
      subjectName: map['subject_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (subjectId != null) 'subject_id': subjectId,
      'subject_name': subjectName,
      'created_at': createdAt,
    };
  }

  static Future<int> dbInsertSubject(String name) async {
    final db = await DatabaseHelper.instance.database;

    String now = DateTime.now().toIso8601String();

    return await db.insert('Subject', {
      'subject_name': name,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<SubjectModel>> dbGetAllSubjects() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Subject',
      orderBy: 'subject_id DESC',
    );
    return maps.map((item) => SubjectModel.fromMap(item)).toList();
  }

  IconData getRandomSubjectIcon() {
    final List<IconData> iconPool = [
      Icons.book,
      Icons.school,
      Icons.menu_book,
      Icons.code,
      Icons.import_contacts,
      Icons.architecture,
      Icons.psychology,
      Icons.calculate,
      Icons.science,
      Icons.biotech,
    ];

    if (subjectName.trim().isEmpty) {
      return Icons.help_outline;
    }

    int charSum = 0;
    for (int i = 0; i < subjectName.length; i++) {
      charSum += subjectName.codeUnitAt(i);
    }

    int iconIndex = charSum % iconPool.length;
    return iconPool[iconIndex];
  }
}
