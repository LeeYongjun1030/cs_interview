import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single training session for one question.
class TrainingSession {
  final String id;
  final String userId;
  final String questionId;
  final String subject;
  final String category;
  final String questionText;

  // 3-Step Answers
  final String stepA; // 한 문장 답변
  final String stepB; // 원리 + 2~3문장
  final String stepC; // 예시/경험/비유

  // AI Follow-up
  final String? aiFollowUpQuestion;
  final String? userFollowUpAnswer;

  // 6-Axis Checklist Evaluation
  final TrainingEvaluation? evaluation;

  final DateTime createdAt;
  final TrainingStatus status;

  TrainingSession({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.subject,
    required this.category,
    required this.questionText,
    required this.stepA,
    required this.stepB,
    required this.stepC,
    this.aiFollowUpQuestion,
    this.userFollowUpAnswer,
    this.evaluation,
    required this.createdAt,
    required this.status,
  });

  /// Combined answer from all 3 steps.
  String get combinedAnswer => '$stepA\n\n$stepB\n\n$stepC';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      'subject': subject,
      'category': category,
      'questionText': questionText,
      'stepA': stepA,
      'stepB': stepB,
      'stepC': stepC,
      'aiFollowUpQuestion': aiFollowUpQuestion,
      'userFollowUpAnswer': userFollowUpAnswer,
      'evaluation': evaluation?.toJson(),
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
      stepA: json['stepA'] as String? ?? '',
      stepB: json['stepB'] as String? ?? '',
      stepC: json['stepC'] as String? ?? '',
      aiFollowUpQuestion: json['aiFollowUpQuestion'] as String?,
      userFollowUpAnswer: json['userFollowUpAnswer'] as String?,
      evaluation: json['evaluation'] != null
          ? TrainingEvaluation.fromJson(
              json['evaluation'] as Map<String, dynamic>)
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

/// 6-axis checklist evaluation result from AI.
class TrainingEvaluation {
  final int summaryScore; // 한 문장 요약(두괄식)  0~100
  final int principleScore; // 원리 설명            0~100
  final int exampleScore; // 예시/경험              0~100
  final int keywordScore; // 핵심 키워드            0~100
  final int clarityScore; // 흐름/명확성            0~100
  final int followUpScore; // 꼬리 질문 대응        0~100

  final int totalScore; // 총점 (평균)
  final String grade; // A/B/C/D/F

  final List<ChecklistItem> mainChecklist;
  final List<ChecklistItem> followUpChecklist;
  final String? improvementTip;

  TrainingEvaluation({
    required this.summaryScore,
    required this.principleScore,
    required this.exampleScore,
    required this.keywordScore,
    required this.clarityScore,
    required this.followUpScore,
    required this.totalScore,
    required this.grade,
    required this.mainChecklist,
    required this.followUpChecklist,
    this.improvementTip,
  });

  /// Convenience getter for radar chart data.
  Map<String, int> get axisScores => {
        'summary': summaryScore,
        'principle': principleScore,
        'example': exampleScore,
        'keyword': keywordScore,
        'clarity': clarityScore,
        'followUp': followUpScore,
      };

  Map<String, dynamic> toJson() {
    return {
      'summaryScore': summaryScore,
      'principleScore': principleScore,
      'exampleScore': exampleScore,
      'keywordScore': keywordScore,
      'clarityScore': clarityScore,
      'followUpScore': followUpScore,
      'totalScore': totalScore,
      'grade': grade,
      'mainChecklist': mainChecklist.map((e) => e.toJson()).toList(),
      'followUpChecklist': followUpChecklist.map((e) => e.toJson()).toList(),
      'improvementTip': improvementTip,
    };
  }

  factory TrainingEvaluation.fromJson(Map<String, dynamic> json) {
    return TrainingEvaluation(
      summaryScore: json['summaryScore'] as int? ?? 0,
      principleScore: json['principleScore'] as int? ?? 0,
      exampleScore: json['exampleScore'] as int? ?? 0,
      keywordScore: json['keywordScore'] as int? ?? 0,
      clarityScore: json['clarityScore'] as int? ?? 0,
      followUpScore: json['followUpScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      grade: json['grade'] as String? ?? 'F',
      mainChecklist: (json['mainChecklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      followUpChecklist: (json['followUpChecklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      improvementTip: json['improvementTip'] as String?,
    );
  }
}

/// A single checklist criterion with pass/fail and optional comment.
class ChecklistItem {
  final String criterion;
  final bool passed;
  final String? comment;

  ChecklistItem({
    required this.criterion,
    required this.passed,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'passed': passed,
      'comment': comment,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      criterion: json['criterion'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
      comment: json['comment'] as String?,
    );
  }
}
