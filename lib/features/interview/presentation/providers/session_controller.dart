import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/question_model.dart';
import '../../data/repositories/interview_repository.dart';
import '../../../../core/services/ai_service.dart';

// Represents one "Round" of an interview (Main Question + Optional Follow-up)
class SessionRound {
  final Question mainQuestion;
  String? mainAnswer;
  GradeResult? mainGrade;

  String? followUpQuestion;
  String? followUpAnswer;
  GradeResult? followUpGrade;

  SessionRound({required this.mainQuestion});

  bool get isFollowUpActive =>
      mainAnswer != null && followUpQuestion != null && followUpAnswer == null;
  bool get isCompleted =>
      mainAnswer != null &&
      (followUpQuestion == null || followUpAnswer != null);
}

class SessionController extends ChangeNotifier {
  final InterviewRepository _repository;
  final AIService _aiService;

  bool _isLoading = false;
  bool _isAiThinking = false; // "Thinking..." state

  bool get isLoading => _isLoading;
  bool get isAiThinking => _isAiThinking;

  SessionController({InterviewRepository? repository, AIService? aiService})
      : _repository = repository ?? InterviewRepository(),
        _aiService = aiService ?? AIService();

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  String _sessionTitle = '';
  String get sessionTitle => _sessionTitle;

  List<SessionRound> _rounds = [];
  List<SessionRound> get rounds =>
      List.unmodifiable(_rounds); // Expose rounds safely
  int _currentIndex = 0;

  // Public accessors
  SessionRound? get currentRound =>
      _rounds.isNotEmpty && _currentIndex < _rounds.length
          ? _rounds[_currentIndex]
          : null;

  Question? get currentQuestion =>
      currentRound?.mainQuestion; // Compatible with existing UI

  // Check if we are in Follow-Up mode for the current round
  bool get isFollowUpMode => currentRound?.isFollowUpActive ?? false;

  int get currentIndex => _currentIndex;
  int get totalQuestions => _rounds.length;
  bool get isSessionFinished => _currentIndex >= _rounds.length;

  Future<String> startNewSession(String userId, String title) async {
    _setLoading(true);
    _currentIndex = 0;
    _rounds = [];
    _currentSessionId = null;
    _sessionTitle = title;

    try {
      final allQuestions = await _repository.fetchAllQuestions();
      if (allQuestions.isEmpty) throw Exception('No questions available');

      // 1. Select Questions
      final selectedQuestions = _selectRandomQuestions(allQuestions);

      // 2. Create Rounds
      _rounds =
          selectedQuestions.map((q) => SessionRound(mainQuestion: q)).toList();

      // 3. Create Session in DB (store IDs)
      final sessionId = await _repository.createSession(
        userId: userId,
        title: title,
        questions: selectedQuestions,
      );

      _currentSessionId = sessionId;
      return sessionId;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitAnswer(String answerText) async {
    if (_currentSessionId == null || currentRound == null) return;

    // Determine if this is a main answer or follow-up answer
    final round = currentRound!;
    _setAiThinking(true);

    try {
      if (!round.isFollowUpActive) {
        // --- 1. Main Answer Submission ---
        round.mainAnswer = answerText;
        notifyListeners(); // Update UI immediately to show local echo if needed

        // Call AI for Grading & Follow-up Trigger
        final result = await _aiService.evaluateAnswer(
          question: round.mainQuestion,
          userAnswer: answerText,
        );

        round.mainGrade = result;

        if (result.followUpQuestion != null) {
          // AI wants to dig deeper!
          round.followUpQuestion = result.followUpQuestion;
          // State: isFollowUpActive becomes true automatically
        } else {
          // No follow-up, move to next round immediately or wait for user?
          // For now, auto-advance to keep flow fast.
          _moveToNext();
        }
      } else {
        // --- 2. Follow-Up Answer Submission ---
        round.followUpAnswer = answerText;
        notifyListeners();

        // Call AI for Grading Follow-up
        final result = await _aiService.evaluateAnswer(
          question: round.mainQuestion, // Context is main question
          userAnswer: answerText,
          previousFollowUp: round.followUpQuestion, // Provide context
        );

        round.followUpGrade = result;
        // Follow-up always ends the round in this MVP (Depth 1)
        _moveToNext();
      }
    } catch (e) {
      // Error handling: maybe just move on?
      // user should not be stuck
      _moveToNext();
    } finally {
      _setAiThinking(false);
    }
  }

  // Skip the current follow-up (Pass)
  void passFollowUp() {
    if (currentRound == null || !currentRound!.isFollowUpActive) return;

    // Mark as skipped
    currentRound!.followUpAnswer = "[SKIPPED]";
    _moveToNext();
  }

  void _moveToNext() {
    _currentIndex++;
    notifyListeners();
  }

  List<Question> _selectRandomQuestions(List<Question> allQuestions) {
    final random = Random();
    final available = List<Question>.from(allQuestions);
    available.shuffle(random);
    return available.take(3).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAiThinking(bool value) {
    _isAiThinking = value;
    notifyListeners();
  }
}
