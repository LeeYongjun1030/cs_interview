import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single training session for one question.
class TrainingSession {
  final String id;
  final String userId;
  final String questionId;
  final String subject;
  final String category;
  final String questionText;

  // User's answer (single input)
  final String userAnswer;

  // AI Follow-up (optional)
  final String? aiFollowUpQuestion;
  final String? aiFollowUpModelAnswer;
  final String? userFollowUpAnswer;

  // AI Feedback
  final TrainingFeedback? feedback;

  final DateTime createdAt;
  final TrainingStatus status;

  TrainingSession({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.subject,
    required this.category,
    required this.questionText,
    required this.userAnswer,
    this.aiFollowUpQuestion,
    this.aiFollowUpModelAnswer,
    this.userFollowUpAnswer,
    this.feedback,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      'subject': subject,
      'category': category,
      'questionText': questionText,
      'userAnswer': userAnswer,
      'aiFollowUpQuestion': aiFollowUpQuestion,
      'aiFollowUpModelAnswer': aiFollowUpModelAnswer,
      'userFollowUpAnswer': userFollowUpAnswer,
      'feedback': feedback?.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      questionId: json['questionId'] as String? ?? '',
      subject: json['subject'] as String? ?? 'unknown',
      category: json['category'] as String? ?? 'unknown',
      questionText: json['questionText'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      aiFollowUpQuestion: json['aiFollowUpQuestion'] as String?,
      aiFollowUpModelAnswer: json['aiFollowUpModelAnswer'] as String?,
      userFollowUpAnswer: json['userFollowUpAnswer'] as String?,
      feedback: json['feedback'] != null
          ? TrainingFeedback.fromJson(
              json['feedback'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: TrainingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TrainingStatus.inProgress,
      ),
    );
  }
}

enum TrainingStatus { inProgress, completed }

/// Simple feedback result from AI evaluation.
class TrainingFeedback {
  final int score; // 0~100
  final List<String> strengths; // 잘한 점
  final List<String> improvements; // 개선할 점
  final List<String> missingKeywords; // 빠진 키워드
  final String? followUpQuestion; // 꼬리질문
  final String? followUpModelAnswer; // 꼬리질문 모범답안

  TrainingFeedback({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.missingKeywords,
    this.followUpQuestion,
    this.followUpModelAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'strengths': strengths,
      'improvements': improvements,
      'missingKeywords': missingKeywords,
      'followUpQuestion': followUpQuestion,
      'followUpModelAnswer': followUpModelAnswer,
    };
  }

  factory TrainingFeedback.fromJson(Map<String, dynamic> json) {
    return TrainingFeedback(
      score: json['score'] as int? ?? 0,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      improvements: (json['improvements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      missingKeywords: (json['missingKeywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      followUpQuestion: json['followUpQuestion'] as String?,
      followUpModelAnswer: json['followUpModelAnswer'] as String?,
    );
  }
}
