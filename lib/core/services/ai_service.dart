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

  Future<GradeResult> evaluateAnswer({
    required Question question,
    required String userAnswer,
    String? previousFollowUp,
  }) async {
    // 1. Construct the prompt
    final prompt = _buildPrompt(question, userAnswer, previousFollowUp);

    try {
      // 2. Call Gemini
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) throw Exception('Empty response from AI');

      // 3. Parse JSON
      // Clean up markdown code blocks if present (```json ... ```)
      final cleanJson = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return GradeResult(
        score: data['score'] as int? ?? 0,
        feedback: data['feedback'] as String? ?? '분석 실패',
        followUpQuestion:
            data['followUp'] as String?, // Null if "PASS" or end of depth
      );
    } catch (e) {
      // print('AI Logic Error: $e');
      // Fallback result in case of error
      return GradeResult(
        score: 0,
        feedback: 'AI 분석 중 오류가 발생했습니다. ($e)',
        followUpQuestion: null,
      );
    }
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
