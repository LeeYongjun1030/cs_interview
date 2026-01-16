import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/interview/domain/models/question_model.dart';

class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> seedData() async {
    // 0. Pre-check Auth: Bypass for development
    // if (FirebaseAuth.instance.currentUser == null) {
    //   return 'Error: You must be logged in to seed data to Firestore.\nPlease login first.';
    // }

    final StringBuffer logs = StringBuffer();
    int successCount = 0;
    
    // logs.writeln('Starts seeding from CSV (Authenticated: ${FirebaseAuth.instance.currentUser?.email})...');
    logs.writeln('Starts seeding from CSV (Auth Bypassed)...');

    try {
      final content = await rootBundle.loadString('questions/questions.csv');

      final rows = content.split('\n');
      if (rows.length < 2) {
        return 'Error: CSV file is empty or has only header.';
      }

      final List<Question> questions = [];
      
      // Parse CSV (Skip header)
      for (int i = 1; i < rows.length; i++) {
        final line = rows[i].trim();
        if (line.isEmpty) continue;

        // Simple CSV parsing (handling quoted strings)
        // Note: This is a basic parser. For complex CSVs, use csv package.
        // Assuming the user's CSV is well-formed.
        final List<String> cells = _parseCsvLine(line);
        if (cells.length < 6) {
          logs.writeln('Skipping invalid line $i: $line');
          continue;
        }

        // Columns: 과목,질문,꿀팁 한문장,난이도,키워드들,카테고리들
        final subjectRaw = cells[0].trim();
        final questionText = cells[1].trim();
        final tipText = cells[2].trim();
        final difficultyStr = cells[3].trim();
        final keywordsStr = cells[4].trim();
        final categoryRaw = cells[5].trim();
        
        // Map Difficulty to Level
        int level = 1; // Bronze
        if (difficultyStr == '중') level = 2; // Silver
        if (difficultyStr == '상') level = 3; // Gold

        // Map Subject Raw to English Key (used for ID and Subject field)
        String subjectKey = 'etc';
        if (subjectRaw == '컴퓨터구조') subjectKey = 'computer_architecture';
        if (subjectRaw == '운영체제') subjectKey = 'operating_system';
        if (subjectRaw == '네트워크') subjectKey = 'network';
        if (subjectRaw == '데이터베이스') subjectKey = 'database';
        if (subjectRaw == '자료구조') subjectKey = 'data_structure';
        if (subjectRaw == '자바') subjectKey = 'java';
        if (subjectRaw == '자바스크립트') subjectKey = 'javascript';
        if (subjectRaw == '알고리즘') subjectKey = 'algorithm';

        questions.add(Question(
          id: '${subjectKey}_${i.toString().padLeft(3, '0')}',
          subject: subjectKey,
          category: categoryRaw, // Specific sub-topic from CSV
          question: questionText,
          tip: tipText,
          depth: 0,
          keywords: keywordsStr.split(',').map((e) => e.trim()).toList(),
          level: level,
        ));
      }


      logs.writeln('Parsed ${questions.length} questions from CSV.');

      if (questions.isNotEmpty) {

        final batch = _firestore.batch();
        for (final q in questions) {
          final docRef = _firestore.collection('questions').doc(q.id);
          batch.set(docRef, q.toJson());
        }
        await batch.commit();
        successCount = questions.length;

      }

    } catch (e) {
      logs.writeln('Failed: $e');

    }

    final result = 'Completed. Total Questions Uploaded: $successCount.\nLogs:\n$logs';

    return result;
  }

  // Helper for parsing CSV lines with quotes
  List<String> _parseCsvLine(String line) {
    List<String> result = [];
    bool inQuote = false;
    StringBuffer current = StringBuffer();
    
    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      
      if (char == '"') {
        inQuote = !inQuote;
      } else if (char == ',' && !inQuote) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
