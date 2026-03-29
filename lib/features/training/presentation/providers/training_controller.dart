import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../interview/data/repositories/interview_repository.dart';
import '../../../interview/domain/models/question_model.dart';
import '../../../../core/services/ai_service.dart';
import '../../domain/models/training_session_model.dart';
import '../../../../core/services/notification_service.dart';

/// Current step in the training flow.
enum TrainingStep {
  stepA, // 한 문장 답변
  stepB, // 원리 + 2~3문장
  stepC, // 예시/경험/비유
  stepD, // AI 꼬리질문 생성 (로딩)
  stepE, // 사용자 꼬리 답변 입력
  stepF, // AI 평가 결과
}

class TrainingController extends ChangeNotifier {
  final InterviewRepository _repository;
  final AIService _aiService;

  TrainingController({
    InterviewRepository? repository,
    AIService? aiService,
  })  : _repository = repository ?? InterviewRepository(),
        _aiService = aiService ?? AIService();

  // --- State ---
  TrainingStep _currentStep = TrainingStep.stepA;
  TrainingStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _loadingMessage = '';
  String get loadingMessage => _loadingMessage;

  Question? _question;
  Question? get question => _question;

  // 3-step answers
  String _stepA = '';
  String _stepB = '';
  String _stepC = '';
  String get stepA => _stepA;
  String get stepB => _stepB;
  String get stepC => _stepC;

  String get combinedAnswer => '$_stepA\n\n$_stepB\n\n$_stepC';

  // Follow-up
  String? _followUpQuestion;
  String? get followUpQuestion => _followUpQuestion;

  String _followUpAnswer = '';
  String get followUpAnswer => _followUpAnswer;

  // Evaluation
  TrainingEvaluation? _evaluation;
  TrainingEvaluation? get evaluation => _evaluation;

  String? _languageCode;

  int get stepNumber {
    switch (_currentStep) {
      case TrainingStep.stepA:
        return 1;
      case TrainingStep.stepB:
        return 2;
      case TrainingStep.stepC:
        return 3;
      case TrainingStep.stepD:
      case TrainingStep.stepE:
        return 4;
      case TrainingStep.stepF:
        return 5;
    }
  }

  // --- Actions ---

  /// Initialize training for a specific question.
  void startTraining(Question question, {String? languageCode}) {
    _question = question;
    _languageCode = languageCode ?? 'ko';
    _currentStep = TrainingStep.stepA;
    _stepA = '';
    _stepB = '';
    _stepC = '';
    _followUpQuestion = null;
    _followUpAnswer = '';
    _evaluation = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Submit Step A answer and move to Step B.
  void submitStepA(String answer) {
    _stepA = answer;
    _currentStep = TrainingStep.stepB;
    notifyListeners();
  }

  /// Submit Step B answer and move to Step C.
  void submitStepB(String answer) {
    _stepB = answer;
    _currentStep = TrainingStep.stepC;
    notifyListeners();
  }

  /// Submit Step C answer and trigger AI follow-up generation.
  Future<void> submitStepC(String answer) async {
    _stepC = answer;
    _currentStep = TrainingStep.stepD;
    _isLoading = true;
    _loadingMessage = _languageCode == 'en'
        ? 'Generating follow-up question...'
        : '꼬리 질문을 생성하고 있습니다...';
    notifyListeners();

    try {
      _followUpQuestion = await _aiService.generateFollowUp(
        question: _question!,
        combinedAnswer: combinedAnswer,
        languageCode: _languageCode,
      );
      _currentStep = TrainingStep.stepE;
    } catch (e) {
      // Fallback question
      _followUpQuestion = _languageCode == 'en'
          ? 'Can you elaborate on that?'
          : '좀 더 자세히 설명해 주시겠어요?';
      _currentStep = TrainingStep.stepE;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit follow-up answer and trigger AI full evaluation.
  Future<void> submitFollowUpAnswer(String answer) async {
    _followUpAnswer = answer;
    _isLoading = true;
    _loadingMessage = _languageCode == 'en'
        ? 'Evaluating your answers...'
        : '답변을 평가하고 있습니다...';
    notifyListeners();

    try {
      _evaluation = await _aiService.evaluateTraining(
        question: _question!,
        combinedAnswer: combinedAnswer,
        followUpQuestion: _followUpQuestion ?? '',
        followUpAnswer: answer,
        languageCode: _languageCode,
      );

      _currentStep = TrainingStep.stepF;

      // Save session to Firestore
      await _saveTrainingSession();

      // Update user stats
      await _updateUserStats();
    } catch (e) {
      debugPrint('Evaluation Error: $e');
      // Still move to result with error state
      _currentStep = TrainingStep.stepF;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Go back one step (if possible).
  void goBack() {
    switch (_currentStep) {
      case TrainingStep.stepB:
        _currentStep = TrainingStep.stepA;
        break;
      case TrainingStep.stepC:
        _currentStep = TrainingStep.stepB;
        break;
      default:
        break; // Cannot go back from other steps
    }
    notifyListeners();
  }

  Future<void> _saveTrainingSession() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _question == null) return;

    final session = TrainingSession(
      id: '',
      userId: uid,
      questionId: _question!.id,
      subject: _question!.subject,
      category: _question!.category,
      questionText: _question!.getLocalizedQuestion(_languageCode ?? 'ko'),
      stepA: _stepA,
      stepB: _stepB,
      stepC: _stepC,
      aiFollowUpQuestion: _followUpQuestion,
      userFollowUpAnswer: _followUpAnswer,
      evaluation: _evaluation,
      createdAt: DateTime.now(),
      status: TrainingStatus.completed,
    );

    try {
      await _repository.saveTrainingSession(session);
      // Trigger follow-up notifications for tomorrow + day after
      await NotificationService().onTrainingCompleted();
    } catch (e) {
      debugPrint('Failed to save training session: $e');
    }
  }

  Future<void> _updateUserStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _evaluation == null) return;

    try {
      final currentStats = await _repository.getUserStats(uid);
      final updatedStats =
          currentStats.withNewEvaluation(_evaluation!.axisScores);
      await _repository.saveUserStats(updatedStats);
    } catch (e) {
      debugPrint('Failed to update user stats: $e');
    }
  }
}
