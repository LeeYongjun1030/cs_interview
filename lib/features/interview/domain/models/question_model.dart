import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String subject; // e.g., 'network' (Broad topic)
  final String category; // e.g., 'OSI 7 Layer' (Specific sub-topic)
  final String question;
  final String tip;
  final int depth;
  final List<String> keywords;
  final int level; // Replaces 'tier' (1: Bronze, 2: Silver, 3: Gold)

  Question({
    required this.id,
    required this.subject,
    required this.category,
    required this.question,
    required this.tip,
    required this.depth,
    required this.keywords,
    required this.level,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? 'etc',
      category: json['category'] as String? ?? 'General',
      question: json['question'] as String,
      tip: json['tip'] as String? ?? '',
      depth: json['depth'] as int? ?? 0,
      keywords: List<String>.from(json['keywords'] ?? []),
      level: json['level'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'category': category,
      'question': question,
      'tip': tip,
      'depth': depth,
      'keywords': keywords,
      'level': level,
    };
  }
}
