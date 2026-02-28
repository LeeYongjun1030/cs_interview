import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../features/interview/domain/models/question_model.dart';
import '../../features/training/domain/models/training_session_model.dart';

class GradeResult {
  final int score;

  final String? followUpQuestion;
  final String? followUpModelAnswer; // New field

  // New Structured Fields
  final String? summary;
  final List<String>? strengths;
  final List<String>? weaknesses;
  final String? tip;

  GradeResult({
    required this.score,
    this.followUpQuestion,
    this.followUpModelAnswer,
    this.summary,
    this.strengths,
    this.weaknesses,
    this.tip,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'tip': tip,
    };
  }

  factory GradeResult.fromJson(Map<String, dynamic> json) {
    return GradeResult(
      score: json['score'] as int? ?? 0,
      followUpQuestion: json['followUpQuestion'] as String?,
      followUpModelAnswer: json['followUpModelAnswer'] as String?,
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
  String toString() => 'Score: $score, Summary: $summary';
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
  static const bool useMockApi = false;
  // ----------------------------------------------------------------------

  // ======================================================================
  // LEGACY: Interview-mode evaluation (kept for backward compatibility)
  // ======================================================================

  Future<GradeResult> evaluateAnswer({
    required Question question,
    required String userAnswer,
    String? previousFollowUp,
    String? languageCode, // 'en' or 'ko'
  }) async {
    if (useMockApi) {
      return _simulateMockResponse(userAnswer, previousFollowUp, languageCode);
    }

    final prompt =
        _buildPrompt(question, userAnswer, previousFollowUp, languageCode);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) throw Exception('Empty response from AI');

      final cleanJson = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return GradeResult(
        score: data['score'] as int? ?? 0,
        followUpQuestion: data['followUp'] as String?,
        followUpModelAnswer: data['followUpModelAnswer'] as String?,
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
        summary: 'AI Error: $e',
        followUpQuestion: null,
      );
    }
  }

  // ======================================================================
  // TRAINING MODE: Follow-up generation + 6-axis checklist evaluation
  // ======================================================================

  /// Generate a follow-up question from the user's 3-step combined answer.
  /// AI Call 1 of 2 in training flow.
  Future<String> generateFollowUp({
    required Question question,
    required String combinedAnswer,
    String? languageCode,
  }) async {
    if (useMockApi) {
      return _mockFollowUp(languageCode);
    }

    final prompt = _buildFollowUpPrompt(question, combinedAnswer, languageCode);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from AI');

      final cleanJson = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return data['followUpQuestion'] as String? ??
          (languageCode == 'en'
              ? 'Can you elaborate on that?'
              : '좀 더 자세히 설명해 주시겠어요?');
    } catch (e) {
      print('AI Follow-up Error: $e');
      return languageCode == 'en'
          ? 'Can you elaborate on that?'
          : '좀 더 자세히 설명해 주시겠어요?';
    }
  }

  /// Evaluate the full training: 3-step combined answer + follow-up answer.
  /// AI Call 2 of 2 in training flow. Returns 6-axis checklist evaluation.
  Future<TrainingEvaluation> evaluateTraining({
    required Question question,
    required String combinedAnswer,
    required String followUpQuestion,
    required String followUpAnswer,
    String? languageCode,
  }) async {
    if (useMockApi) {
      return _mockTrainingEvaluation(languageCode);
    }

    final prompt = _buildTrainingEvalPrompt(
      question,
      combinedAnswer,
      followUpQuestion,
      followUpAnswer,
      languageCode,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from AI');

      final cleanJson = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final data = jsonDecode(cleanJson) as Map<String, dynamic>;

      return TrainingEvaluation(
        summaryScore: data['summaryScore'] as int? ?? 0,
        principleScore: data['principleScore'] as int? ?? 0,
        exampleScore: data['exampleScore'] as int? ?? 0,
        keywordScore: data['keywordScore'] as int? ?? 0,
        clarityScore: data['clarityScore'] as int? ?? 0,
        followUpScore: data['followUpScore'] as int? ?? 0,
        totalScore: data['totalScore'] as int? ?? 0,
        grade: data['grade'] as String? ?? 'F',
        mainChecklist: (data['mainChecklist'] as List<dynamic>?)
                ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        followUpChecklist: (data['followUpChecklist'] as List<dynamic>?)
                ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        improvementTip: data['improvementTip'] as String?,
      );
    } catch (e) {
      print('AI Evaluation Error: $e');
      return TrainingEvaluation(
        summaryScore: 0,
        principleScore: 0,
        exampleScore: 0,
        keywordScore: 0,
        clarityScore: 0,
        followUpScore: 0,
        totalScore: 0,
        grade: 'F',
        mainChecklist: [],
        followUpChecklist: [],
        improvementTip: 'AI Error: $e',
      );
    }
  }

  // ======================================================================
  // PROMPT BUILDERS
  // ======================================================================

  String _buildFollowUpPrompt(
      Question question, String combinedAnswer, String? languageCode) {
    final isEnglish = languageCode == 'en';
    final langInstruction = isEnglish ? 'English' : 'Korean';
    final safeLangCode = languageCode ?? 'ko';

    return '''
You are a rigorous CS technical interviewer.
The candidate has answered a question in 3 structured steps. Based on their answer, generate ONE challenging follow-up question.

[Context]
Subject: ${question.getLocalizedCategory(safeLangCode)}
Main Question: ${question.getLocalizedQuestion(safeLangCode)}
Candidate's Answer: "$combinedAnswer"

[Instructions]
1. Identify a keyword, concept, or trade-off the candidate mentioned.
2. Generate a follow-up question that probes deeper understanding.
3. The question should challenge "why" or "how" or test an edge case.
4. MUST be in $langInstruction.

[Output Format]
Return ONLY a JSON object:
{
  "followUpQuestion": "<string>"
}
''';
  }

  String _buildTrainingEvalPrompt(
    Question question,
    String combinedAnswer,
    String followUpQuestion,
    String followUpAnswer,
    String? languageCode,
  ) {
    final isEnglish = languageCode == 'en';
    final langInstruction = isEnglish ? 'English' : 'Korean';
    final safeLangCode = languageCode ?? 'ko';

    return '''
You are evaluating a CS interview answer using a 6-axis checklist system.
The candidate answered in 3 steps, then responded to a follow-up question.

[Context]
Subject: ${question.getLocalizedCategory(safeLangCode)}
Main Question: ${question.getLocalizedQuestion(safeLangCode)}
Keywords the answer should reference: ${question.getLocalizedKeywords(safeLangCode).join(', ')}

[Candidate's Main Answer (3-step combined)]
"$combinedAnswer"

[Follow-Up Question]
"$followUpQuestion"

[Candidate's Follow-Up Answer]
"$followUpAnswer"

[Evaluation Axes - Score each 0~100]
1. **summaryScore** (한 문장 요약/두괄식): Did the answer start with a clear, concise one-sentence summary?
2. **principleScore** (원리 설명): Did the answer explain the underlying principle or mechanism?
3. **exampleScore** (예시/경험): Did the answer include concrete examples, analogies, or real experience?
4. **keywordScore** (핵심 키워드): Did the answer include the essential technical keywords?
5. **clarityScore** (흐름/명확성): Is the answer logically structured and easy to follow?
6. **followUpScore** (꼬리 질문 대응): How well did the candidate handle the follow-up question?

[Checklist Items]
For both main answer and follow-up answer, provide a checklist of 3-5 criteria each:
- criterion: What was being checked
- passed: true/false
- comment: Brief note (if failed or noteworthy)

[Grade Scale]
A: 90-100, B: 75-89, C: 60-74, D: 40-59, F: 0-39
totalScore = average of all 6 axis scores.

MUST respond in $langInstruction.

[Output Format]
Return ONLY a JSON object:
{
  "summaryScore": <int>,
  "principleScore": <int>,
  "exampleScore": <int>,
  "keywordScore": <int>,
  "clarityScore": <int>,
  "followUpScore": <int>,
  "totalScore": <int>,
  "grade": "<A|B|C|D|F>",
  "mainChecklist": [
    {"criterion": "<string>", "passed": <bool>, "comment": "<string or null>"}
  ],
  "followUpChecklist": [
    {"criterion": "<string>", "passed": <bool>, "comment": "<string or null>"}
  ],
  "improvementTip": "<string>"
}
''';
  }

  // ======================================================================
  // LEGACY PROMPT (interview mode)
  // ======================================================================

  String _buildPrompt(Question question, String userAnswer,
      String? previousFollowUp, String? languageCode) {
    final isEnglish = languageCode == 'en';
    final langInstruction = isEnglish ? 'English' : 'Korean';

    final safeLangCode = languageCode ?? 'ko';

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
     - **Challenge**: Ask "Why X and not Y?" or "How would this behave under high load?".
     - **Connection**: Relate the concept to a real-world scenario.
     - **Model Answer**: Provide a concise model answer (1-2 sentences) for this follow-up question.
     - **If the answer is perfect or irrelevant**: Return `null` for followUp.
   - If this is already a Follow-Up response (Previous Follow-Up is NOT null):
     - Set "followUp" to null (End of chain).
     - Set "followUpModelAnswer" to null.

[Output Format]
Return ONLY a JSON object:
{
  "score": <int>,
  "summary": "<string>",
  "strengths": ["<string>", "<string>"],
  "weaknesses": ["<string>", "<string>"],
  "tip": "<string or null>",

  "followUp": "<string or null>",
  "followUpModelAnswer": "<string or null>"
}
''';
  }

  // ======================================================================
  // MOCK IMPLEMENTATIONS (for development)
  // ======================================================================

  Future<GradeResult> _simulateMockResponse(
      String userAnswer, String? previousFollowUp, String? languageCode) async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

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
      summary: isEnglish ? 'Good answer!' : '좋은 답변입니다!',
      strengths: isEnglish
          ? ['Clear explanation', 'Good terminology']
          : ['명확한 설명', '적절한 용어 사용'],
      weaknesses: isEnglish ? ['Missed edge case'] : ['엣지 케이스 누락'],
      tip: isEnglish ? 'Mention time complexity.' : '시간 복잡도를 언급하면 더 좋습니다.',
      followUpQuestion: mockFollowUp,
      followUpModelAnswer: isFollowUpResponse
          ? null
          : (isEnglish
              ? 'This is a mock model answer for the follow-up question.'
              : '이것은 꼬리질문에 대한 모의 모범 답안입니다.'),
    );
  }

  Future<String> _mockFollowUp(String? languageCode) async {
    await Future.delayed(const Duration(seconds: 1));
    return languageCode == 'en'
        ? 'How does this behave differently under high concurrency? (Mock)'
        : '높은 동시성 환경에서는 이것이 어떻게 다르게 동작하나요? (Mock 꼬리질문)';
  }

  Future<TrainingEvaluation> _mockTrainingEvaluation(
      String? languageCode) async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    final isEnglish = languageCode == 'en';

    return TrainingEvaluation(
      summaryScore: 80,
      principleScore: 70,
      exampleScore: 85,
      keywordScore: 75,
      clarityScore: 78,
      followUpScore: 65,
      totalScore: 76,
      grade: 'B',
      mainChecklist: [
        ChecklistItem(
          criterion:
              isEnglish ? 'Starts with clear one-liner' : '명확한 한 문장 요약으로 시작',
          passed: true,
          comment: null,
        ),
        ChecklistItem(
          criterion: isEnglish ? 'Explains underlying principle' : '동작 원리 설명',
          passed: true,
          comment: null,
        ),
        ChecklistItem(
          criterion: isEnglish ? 'Includes concrete example' : '구체적인 예시 포함',
          passed: true,
          comment: null,
        ),
        ChecklistItem(
          criterion: isEnglish ? 'Uses key technical terms' : '핵심 키워드 사용',
          passed: false,
          comment: isEnglish ? 'Missing "mutex" keyword' : '"mutex" 키워드 누락',
        ),
      ],
      followUpChecklist: [
        ChecklistItem(
          criterion:
              isEnglish ? 'Directly addresses the question' : '질문에 직접 답변',
          passed: true,
          comment: null,
        ),
        ChecklistItem(
          criterion:
              isEnglish ? 'Provides depth beyond surface' : '표면적 지식 이상의 깊이',
          passed: false,
          comment: isEnglish ? 'Needs more depth' : '더 깊은 설명 필요',
        ),
      ],
      improvementTip: isEnglish
          ? 'Try to mention specific data structures and their time complexities.'
          : '구체적인 자료구조와 시간 복잡도를 언급해 보세요.',
    );
  }
}
