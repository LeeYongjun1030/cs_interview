import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../features/interview/domain/models/question_model.dart';

class GradeResult {
  final int score;
  final String feedback; // Legacy or Full Combined Text
  final String? followUpQuestion;

  // New Structured Fields
  final String? summary;
  final List<String>? strengths;
  final List<String>? weaknesses;
  final String? tip;

  GradeResult({
    required this.score,
    required this.feedback,
    this.followUpQuestion,
    this.summary,
    this.strengths,
    this.weaknesses,
    this.tip,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'feedback': feedback,
      'followUpQuestion': followUpQuestion,
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'tip': tip,
    };
  }

  factory GradeResult.fromJson(Map<String, dynamic> json) {
    return GradeResult(
      score: json['score'] as int? ?? 0,
      feedback: json['feedback'] as String? ?? '',
      followUpQuestion: json['followUpQuestion'] as String?,
      summary: json['summary'] as String?,
      strengths: (json['strengths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      tip: json['tip'] as String?,
    );
  }

  @override
  String toString() => 'Score: $score, Summary: $summary, Feedback: $feedback';
}

class AIService {
  late GenerativeModel _model;
  final _remoteConfig = FirebaseRemoteConfig.instance;

  // Initialize in main.dart or via a provider/singleton
  AIService() {
    _initModel();
    _listenForConfigUpdates();
  }

  void _initModel() {
    final modelName = _remoteConfig.getString('model_name');
    print('🤖 AI Service Initialized with Model: $modelName');

    _model = FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON output
      ),
    );
  }

  void _listenForConfigUpdates() {
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      print('🔄 Remote Config Updated. Reloading AI Model...');
      _initModel();
    });
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
        summary: data['summary'] as String?,
        strengths: (data['strengths'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        weaknesses: (data['weaknesses'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        tip: data['tip'] as String?,
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
      feedback: 'Mock Feedback',
      summary: isEnglish ? 'Good answer!' : '좋은 답변입니다!',
      strengths: isEnglish
          ? ['Clear explanation', 'Good terminology']
          : ['명확한 설명', '적절한 용어 사용'],
      weaknesses: isEnglish ? ['Missed edge case'] : ['엣지 케이스 누락'],
      tip: isEnglish ? 'Mention time complexity.' : '시간 복잡도를 언급하면 더 좋습니다.',
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
3. **Structured Feedback** (Crucial):
   - **Summary**: A one-line verdict on the answer.
   - **Strengths**: List 1-3 specific things the candidate did well.
   - **Weaknesses**: List 1-3 specific things missing or incorrect.
   - **Pro Tip**: A practical tip or industry insight related to the topic.
   - **MUST be in $langInstruction**.
4. **Follow-Up (Critical Step)**:
     - **Dig Deeper (Crucial)**: Latch onto a specific keyword, technology, or trade-off the candidate mentioned.
     - **"Catch the Tail"**: If they explained A, ask about the edge case of A. If they proposed B, ask why not C.
     - **Be Skeptical**: Do not accept surface-level answers. Ask "Why?" or "How exactly?" regarding their specific implementation detail.
     - **Contextual**: Start the question with "You mentioned [Keyword]...", "You said...", or "In that specific case...".
     - Example: "You mentioned specific indexes, but how does that impact write performance in high-concurrency systems?" (Not just "What is an index?")
     - **MUST be a sharp, technical, and challenging follow-up in $langInstruction**.
     - **Even if the answer is perfect, DO NOT return null. Ask a more advanced question.**
   - If this is already a Follow-Up response (Previous Follow-Up is NOT null):
     - Set "followUp" to null (End of chain).

[Output Format]
Return ONLY a JSON object:
{
  "score": <int>,
  "summary": "<string>",
  "strengths": ["<string>", "<string>"],
  "weaknesses": ["<string>", "<string>"],
  "tip": "<string or null>",
  "feedback": "<string (Legacy, put the summary here too)>",
  "followUp": "<string or null>"
}
''';
  }
}
