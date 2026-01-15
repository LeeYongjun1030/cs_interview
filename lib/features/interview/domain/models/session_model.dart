import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { active, completed, aborted }

class InterviewSession {
  final String id;
  final String userId;
  final String title; // Added title
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SessionQuestionItem> questions;

  InterviewSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'status': status.name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? '무제 세션',
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => SessionQuestionItem.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SessionQuestionItem {
  final String questionId;
  final String questionText;
  String userAnswerText;
  String? userAnswerAudioUrl;
  String? aiFollowUp;
  String? userFollowUpAnswer;
  Map<String, dynamic>? evaluation; // result, score, feedback

  SessionQuestionItem({
    required this.questionId,
    required this.questionText,
    this.userAnswerText = '',
    this.userAnswerAudioUrl,
    this.aiFollowUp,
    this.userFollowUpAnswer,
    this.evaluation,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'userAnswerText': userAnswerText,
      'userAnswerAudioUrl': userAnswerAudioUrl,
      'aiFollowUp': aiFollowUp,
      'userFollowUpAnswer': userFollowUpAnswer,
      'evaluation': evaluation,
    };
  }
  factory SessionQuestionItem.fromJson(Map<String, dynamic> json) {
    return SessionQuestionItem(
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      userAnswerText: json['userAnswerText'] as String? ?? '',
      userAnswerAudioUrl: json['userAnswerAudioUrl'] as String?,
      aiFollowUp: json['aiFollowUp'] as String?,
      userFollowUpAnswer: json['userFollowUpAnswer'] as String?,
      evaluation: json['evaluation'] as Map<String, dynamic>?,
    );
  }
}
