import 'package:flutter/material.dart' show IconData, Icons;
import 'package:sqflite/sqflite.dart';
import 'package:flashcard/core/database/database_helper.dart';

class DocumentModel {
  final int? documentId;
  final String folderName;
  final String fileName;
  final String filePath;
  final String summaryContext;
  final String createdAt;
  final int subjectId; 

  DocumentModel({
    this.documentId,
    required this.folderName,
    required this.fileName,
    required this.filePath,
    required this.summaryContext,
    required this.createdAt,
    required this.subjectId,
  });

  
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      documentId: map['document_id'] as int?,
      folderName: map['folder_name'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      summaryContext: map['summary_context'] as String,
      createdAt: map['created_at'] as String,
      subjectId: map['subject_id'] as int,
    );
  }

 
  Map<String, dynamic> toMap() {
    return {
      if (documentId != null) 'document_id': documentId,
      'folder_name': folderName,
      'file_name': fileName,
      'file_path': filePath,
      'summary_context': summaryContext,
      'created_at': createdAt,
      'subject_id': subjectId,
    };
  }

  
  static Future<List<DocumentModel>> dbGetDocumentsBySubject(int subId) async {
    final db = await DatabaseHelper.instance.database;
    
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Document',
      where: 'subject_id = ?',
      whereArgs: [subId],
      orderBy: 'document_id DESC',
    );
    
    return maps.map((item) => DocumentModel.fromMap(item)).toList();
  }

  static Future<int> dbInsertDocument(DocumentModel document) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      'Document',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> dbDeleteDocument(int docId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('Document', where: 'document_id = ?', whereArgs: [docId]);
  }

  static Future<void> dbUpdateDocumentName(int docId, String newName) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'Document',
      {'folder_name': newName},
      where: 'document_id = ?',
      whereArgs: [docId],
    );
  }

  static Future<void> dbUpdateDocumentFile(int docId, String fileName, String filePath) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'Document',
      {'file_name': fileName, 'file_path': filePath},
      where: 'document_id = ?',
      whereArgs: [docId],
    );
  }
  
  IconData getRandomDocumentIcon() {
    final List<IconData> iconPool = [
      Icons.auto_stories,   
      Icons.wb_incandescent, 
      Icons.palette,         
      Icons.rocket_launch,   
      Icons.biotech,         
      Icons.calculate,       
      Icons.extension,     
      Icons.emoji_objects,   
    ];

    if (documentId == null) return Icons.insert_drive_file;
    
    return iconPool[documentId! % iconPool.length];
  }
}
