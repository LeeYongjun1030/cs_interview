import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../interview/data/repositories/interview_repository.dart';
import '../../../interview/domain/models/question_model.dart';
import '../../../../core/services/ai_service.dart';
import '../../domain/models/training_session_model.dart';
import '../../../../core/services/notification_service.dart';

/// Current step in the training flow.
enum TrainingStep {
  answer, // 사용자 답변 입력
  loading, // AI 평가 중
  feedback, // 피드백 + 모범답변 확인
  followUp, // 꼬리질문 답변 (선택)
  followUpResult, // 꼬리질문 모범답안 확인
  done, // 완료 (저장 후)
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
  TrainingStep _currentStep = TrainingStep.answer;
  TrainingStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _loadingMessage = '';
  String get loadingMessage => _loadingMessage;

  Question? _question;
  Question? get question => _question;

  // User's answer
  String _userAnswer = '';
  String get userAnswer => _userAnswer;

  // Follow-up
  String _followUpAnswer = '';
  String get followUpAnswer => _followUpAnswer;

  // AI Feedback
  TrainingFeedback? _feedback;
  TrainingFeedback? get feedback => _feedback;

  String? _languageCode;

  // --- Actions ---

  /// Initialize training for a specific question.
  void startTraining(Question question, {String? languageCode}) {
    _question = question;
    _languageCode = languageCode ?? 'ko';
    _currentStep = TrainingStep.answer;
    _userAnswer = '';
    _followUpAnswer = '';
    _feedback = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Submit answer and trigger AI evaluation (single call).
  Future<void> submitAnswer(String answer) async {
    _userAnswer = answer;
    _currentStep = TrainingStep.loading;
    _isLoading = true;
    _loadingMessage = _languageCode == 'en'
        ? 'Evaluating your answer...'
        : '답변을 평가하고 있습니다...';
    notifyListeners();

    try {
      _feedback = await _aiService.evaluateTrainingAnswer(
        question: _question!,
        userAnswer: answer,
        languageCode: _languageCode,
      );
      _currentStep = TrainingStep.feedback;
    } catch (e) {
      debugPrint('Evaluation Error: $e');
      _currentStep = TrainingStep.feedback;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User wants to skip answering and just see the model answer.
  void skipToAnswer() {
    _userAnswer = ''; // Blank answer indicates skipped
    _feedback = null;
    _currentStep = TrainingStep.feedback;
    notifyListeners();
  }

  /// User chooses to try the follow-up question.
  void startFollowUp() {
    _currentStep = TrainingStep.followUp;
    notifyListeners();
  }

  /// Submit follow-up answer → show model answer.
  void submitFollowUpAnswer(String answer) {
    _followUpAnswer = answer;
    _currentStep = TrainingStep.followUpResult;
    notifyListeners();
  }

  /// Complete training — save to Firestore.
  Future<void> finishTraining() async {
    _currentStep = TrainingStep.done;
    notifyListeners();

    await _saveTrainingSession();
    await _updateUserStats();
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
      userAnswer: _userAnswer,
      aiFollowUpQuestion: _feedback?.followUpQuestion,
      aiFollowUpModelAnswer: _feedback?.followUpModelAnswer,
      userFollowUpAnswer: _followUpAnswer.isNotEmpty ? _followUpAnswer : null,
      feedback: _feedback,
      createdAt: DateTime.now(),
      status: TrainingStatus.completed,
    );

    try {
      await _repository.saveTrainingSession(session);
      await NotificationService().onTrainingCompleted();
    } catch (e) {
      debugPrint('Failed to save training session: $e');
    }
  }

  Future<void> _updateUserStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _feedback == null) return;

    try {
      final currentStats = await _repository.getUserStats(uid);
      final updatedStats =
          currentStats.withNewScore(_feedback!.score);
      await _repository.saveUserStats(updatedStats);
    } catch (e) {
      debugPrint('Failed to update user stats: $e');
    }
  }
}
