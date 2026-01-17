import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import '../../features/interview/domain/models/question_model.dart';

class GradeResult {
  final int score;
  final String feedback;
  final String? followUpQuestion;

  GradeResult({
    required this.score,
    required this.feedback,
    this.followUpQuestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'feedback': feedback,
      'followUpQuestion': followUpQuestion,
    };
  }

  factory GradeResult.fromJson(Map<String, dynamic> json) {
    return GradeResult(
      score: json['score'] as int? ?? 0,
      feedback: json['feedback'] as String? ?? '',
      followUpQuestion: json['followUpQuestion'] as String?,
    );
  }

  @override
  String toString() =>
      'Score: $score, Feedback: $feedback, FollowUp: $followUpQuestion';
}

class AIService {
  late final GenerativeModel _model;

  // Initialize in main.dart or via a provider/singleton
  AIService() {
    // Uses the 'gemini-1.5-flash' model (optimal for speed/cost)
    // Using vertexAI() as we are using Vertex AI in Firebase
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON output
      ),
    );
  }

  // ----------------------------------------------------------------------
  // [Dev Flag] Set to true to bypass AI API and use Mock data
  static const bool useMockApi = true;
  // ----------------------------------------------------------------------

  Future<GradeResult> evaluateAnswer({
    required Question question,
    required String userAnswer,
    String? previousFollowUp,
  }) async {
    // --- Mock Mode Check ---
    if (useMockApi) {
      return _simulateMockResponse(userAnswer, previousFollowUp);
    }

    // 1. Construct the prompt
    final prompt = _buildPrompt(question, userAnswer, previousFollowUp);

    try {
      // 2. Call Gemini
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) throw Exception('Empty response from AI');

      // 3. Parse JSON
      final cleanJson = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return GradeResult(
        score: data['score'] as int? ?? 0,
        feedback: data['feedback'] as String? ?? '분석 실패',
        followUpQuestion: data['followUp'] as String?,
      );
    } catch (e) {
      return GradeResult(
        score: 0,
        feedback: 'AI 분석 중 오류가 발생했습니다. ($e)',
        followUpQuestion: null,
      );
    }
  }

  // --- Mock Logic for Development ---
  Future<GradeResult> _simulateMockResponse(
      String userAnswer, String? previousFollowUp) async {
    await Future.delayed(
        const Duration(seconds: 1, milliseconds: 500)); // Simulate network

    final isFollowUpResponse = previousFollowUp != null;

    // Simulate: If main answer, 50% chance of follow-up
    // If already follow-up, never ask again (depth 1)
    String? mockFollowUp;
    if (!isFollowUpResponse) {
      // Always ask follow-up in Mock mode
      mockFollowUp = '그렇다면, 구체적으로 어떤 상황에서 사용되나요? (Mock 꼬리질문)';
    }

    return GradeResult(
      score: 85,
      feedback: isFollowUpResponse
          ? 'Mock: 꼬리질문에 대한 답변이 훌륭합니다.'
          : 'Mock: 핵심적인 내용을 잘 짚어주셨습니다. (테스트용 응답)',
      followUpQuestion: mockFollowUp,
    );
  }

  String _buildPrompt(
      Question question, String userAnswer, String? previousFollowUp) {
    // Base instruction
    return '''
You are a ferocious technical interviewer in a computer science job interview.
Evaluate the user's answer and decide whether to ask a follow-up question.

[Context]
Subject: ${question.category}
Question: ${previousFollowUp ?? question.question}
User Answer: "$userAnswer"

[Instructions]
1. **Grade** the answer (0-100). Be strict. 0 if irrelevant.
2. **Feedback**: Summarize strengths/weaknesses in 1 Korean sentence.
3. **Follow-Up**:
   - If the answer is vague, incorrect, or mentions a keyword worth digging into, ask a sharp follow-up question (Korean).
   - If the answer is perfect or this is already a follow-up response, set "followUp" to null.
   - Max 1 follow-up allowed per main question. If 'previousFollowUp' was provided in [Context], DO NOT ask another follow-up. Set "followUp" to null.

[Output Format]
Return ONLY a JSON object:
{
  "score": <int>,
  "feedback": "<string>",
  "followUp": "<string or null>"
}
''';
  }
}
