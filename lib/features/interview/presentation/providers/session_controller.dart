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
  String _thinkingMessage = 'AI 면접관이 답변을 분석 중입니다...';

  bool get isLoading => _isLoading;
  bool get isAiThinking => _isAiThinking;
  String get thinkingMessage => _thinkingMessage;

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

  Future<String> startNewSession(String userId, String title,
      {List<String>? targetSubjects}) async {
    _setLoading(true);
    _currentIndex = 0;
    _rounds = [];
    _currentSessionId = null;
    _sessionTitle = title;

    try {
      print('[StartSession] Fetching questions...');
      final allQuestions = await _repository.fetchAllQuestions();
      print('[StartSession] Fetched ${allQuestions.length} questions.');

      if (allQuestions.isEmpty) throw Exception('No questions available in DB');

      // 1. Select Questions (Filter by subject if provided)
      final selectedQuestions =
          _selectRandomQuestions(allQuestions, targetSubjects);

      print(
          '[StartSession] Selected ${selectedQuestions.length} questions for subjects: $targetSubjects');

      if (selectedQuestions.isEmpty) {
        throw Exception('선택한 과목에 해당하는 문제가 없습니다. (요청: $targetSubjects)');
      }

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
      print('[StartSession] Created session with ID: $sessionId');
      return sessionId;
    } catch (e) {
      print('[StartSession] Error: $e');
      rethrow;
    } finally {
      print('[StartSession] Finished (Loading=false)');
      _setLoading(false);
    }
  }

  Future<void> submitAnswer(String answerText) async {
    if (_currentSessionId == null || currentRound == null) return;

    // Determine if this is a main answer or follow-up answer
    final round = currentRound!;

    // Set message based on context
    if (round.isFollowUpActive) {
      _setAiThinking(true, message: '답변 감사합니다.\n다음 면접 질문을 준비 중입니다.');
    } else {
      _setAiThinking(true, message: 'AI 면접관이 답변을 분석 중입니다...');
    }

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

  List<Question> _selectRandomQuestions(
      List<Question> allQuestions, List<String>? targetSubjects) {
    var available = List<Question>.from(allQuestions);

    // Filter if subjects are specified and not empty
    if (targetSubjects != null && targetSubjects.isNotEmpty) {
      final targets = targetSubjects.map((s) => s.toLowerCase()).toSet();
      available = available.where((q) {
        final subject = q.subject.toLowerCase();
        return targets.contains(subject);
      }).toList();
    }

    final random = Random();
    available.shuffle(random);
    return available.take(3).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAiThinking(bool value, {String? message}) {
    _isAiThinking = value;
    if (message != null) {
      _thinkingMessage = message;
    }
    notifyListeners();
  }
}
