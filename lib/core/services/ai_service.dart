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
  // ----------------------------------------------------------------------
  // [Dev Flag] Set to true to bypass AI API and use Mock data
  static const bool useMockApi = false;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------

  Future<GradeResult> evaluateAnswer({
    required Question question,
    required String userAnswer,
    String? previousFollowUp,
    String? languageCode, // 'en' or 'ko'
  }) async {
    // --- Mock Mode Check ---
    if (useMockApi) {
      return _simulateMockResponse(userAnswer, previousFollowUp, languageCode);
    }

    // 1. Construct the prompt
    final prompt =
        _buildPrompt(question, userAnswer, previousFollowUp, languageCode);

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
        feedback: data['feedback'] as String? ?? 'Analysis Failed',
        followUpQuestion: data['followUp'] as String?,
      );
    } catch (e) {
      return GradeResult(
        score: 0,
        feedback: 'AI Error: $e',
        followUpQuestion: null,
      );
    }
  }

  // --- Mock Logic for Development ---
  Future<GradeResult> _simulateMockResponse(
      String userAnswer, String? previousFollowUp, String? languageCode) async {
    await Future.delayed(
        const Duration(seconds: 1, milliseconds: 500)); // Simulate network

    final isFollowUpResponse = previousFollowUp != null;
    final isEnglish = languageCode == 'en';

    String? mockFollowUp;
    if (!isFollowUpResponse) {
      mockFollowUp = isEnglish
          ? 'Then, in what specific situation is it used? (Mock Follow-up)'
          : '그렇다면, 구체적으로 어떤 상황에서 사용되나요? (Mock 꼬리질문)';
    }

    return GradeResult(
      score: 85,
      feedback: isFollowUpResponse
          ? (isEnglish
              ? 'Mock: Great answer to the follow-up.'
              : 'Mock: 꼬리질문에 대한 답변이 훌륭합니다.')
          : (isEnglish
              ? 'Mock: You captured the core points well.'
              : 'Mock: 핵심적인 내용을 잘 짚어주셨습니다.'),
      followUpQuestion: mockFollowUp,
    );
  }

  String _buildPrompt(Question question, String userAnswer,
      String? previousFollowUp, String? languageCode) {
    final isEnglish = languageCode == 'en';
    final langInstruction = isEnglish ? 'English' : 'Korean';

    final safeLangCode = languageCode ?? 'ko';

    // Base instruction
    return '''
You are a ferocious technical interviewer in a computer science job interview.
Your goal is to evaluate the candidate's depth of understanding, not just surface knowledge.

[Context]
Subject: ${question.getLocalizedCategory(safeLangCode)}
Main Question: ${question.getLocalizedQuestion(safeLangCode)}
${previousFollowUp != null ? 'Previous Follow-Up Question: $previousFollowUp' : ''}
Candidate Answer: "$userAnswer"

[Instructions]
1. **Analyze**: Determine if the answer is correct, partial, or wrong.
2. **Grade** (0-100): Be strict. 0 if irrelevant/wrong.
3. **Feedback**:
   - Provide **specific, actionable feedback** in 2-3 sentences.
   - Mention exactly what key concepts were missing or what was explained well.
   - If incorrect, briefly correct it.
   - **MUST be in $langInstruction**.
4. **Follow-Up (Critical Step)**:
   - If this is a Main Question (Previous Follow-Up is null):
     - Dig deeper into a specific keyword or concept the candidate mentioned.
     - OR ask about a missing critical component related to the topic.
     - Example: "You mentioned X, but how does X handle edge case Y?"
     - **MUST be a sharp, technical follow-up question in $langInstruction**.
   - If the answer is perfect or this is already a Follow-Up response:
     - Set "followUp" to null.

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
