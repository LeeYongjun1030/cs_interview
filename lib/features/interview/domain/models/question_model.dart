import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String subject; // e.g., 'network' (Broad topic)
  final String category; // e.g., 'OSI 7 Layer' (Specific sub-topic)
  final String? questionEn; // English Question Text
  final String? tipEn; // English Tip
  final List<String>? keywordsEn; // English Keywords
  final String? categoryEn; // English Category

  final String question;
  final String tip;
  final int depth;
  final List<String> keywords;
  final int level; // Replaces 'tier' (1: Bronze, 2: Silver, 3: Gold)
  final DateTime? lastReviewedAt;

  Question({
    required this.id,
    required this.subject,
    required this.category,
    required this.question,
    this.questionEn,
    required this.tip,
    this.tipEn,
    required this.depth,
    required this.keywords,
    this.keywordsEn,
    this.categoryEn,
    required this.level,
    this.lastReviewedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? 'etc',
      category: json['category'] as String? ?? 'General',
      question: json['question'] as String,
      questionEn: json['questionEn'] as String?,
      tip: json['tip'] as String? ?? '',
      tipEn: json['tipEn'] as String?,
      depth: json['depth'] as int? ?? 0,
      keywords: List<String>.from(json['keywords'] ?? []),
      keywordsEn:
          (json['keywordsEn'] as List?)?.map((e) => e.toString()).toList(),
      categoryEn: json['categoryEn'] as String?,
      level: json['level'] as int? ?? 1,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? (json['lastReviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'category': category,
      'question': question,
      'questionEn': questionEn,
      'tip': tip,
      'tipEn': tipEn,
      'depth': depth,
      'keywords': keywords,
      'keywordsEn': keywordsEn,
      'categoryEn': categoryEn,
      'level': level,
    };
  }

  String getLocalizedQuestion(String languageCode) {
    if (languageCode == 'en' && questionEn != null && questionEn!.isNotEmpty) {
      return questionEn!;
    }
    return question; // Fallback to Korean/Default
  }

  String getLocalizedTip(String languageCode) {
    if (languageCode == 'en' && tipEn != null && tipEn!.isNotEmpty) {
      return tipEn!;
    }
    return tip; // Fallback
  }

  String getLocalizedCategory(String languageCode) {
    if (languageCode == 'en' && categoryEn != null && categoryEn!.isNotEmpty) {
      return categoryEn!;
    }
    return category; // Fallback
  }

  List<String> getLocalizedKeywords(String languageCode) {
    if (languageCode == 'en' && keywordsEn != null && keywordsEn!.isNotEmpty) {
      return keywordsEn!;
    }
    return keywords; // Fallback
  }
}
