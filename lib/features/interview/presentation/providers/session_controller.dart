import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/question_model.dart';
import '../../domain/models/session_model.dart';
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
      {List<String>? targetSubjects, List<Question>? fixedQuestions}) async {
    _setLoading(true);
    _currentIndex = 0;
    _rounds = [];
    _currentSessionId = null;
    _sessionTitle = title;

    try {
      List<Question> selectedQuestions;

      if (fixedQuestions != null && fixedQuestions.isNotEmpty) {
        selectedQuestions = fixedQuestions;
        print(
            '[StartSession] Using fixed questions: ${selectedQuestions.length} items');
      } else {
        print('[StartSession] Fetching questions...');
        final allQuestions = await _repository.fetchAllQuestions();
        print('[StartSession] Fetched ${allQuestions.length} questions.');

        if (allQuestions.isEmpty)
          throw Exception('No questions available in DB');

        // 1. Select Questions (Filter by subject if provided)
        selectedQuestions =
            _selectRandomQuestions(allQuestions, targetSubjects);
      }

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

  String _sessionLanguageCode = 'ko';

  Future<void> submitAnswer(String answerText,
      {String languageCode = 'ko'}) async {
    if (_currentSessionId == null || currentRound == null) return;

    _sessionLanguageCode = languageCode; // capture language code

    final round = currentRound!;
    final isEnglish = languageCode == 'en';

    // Set thinking state
    // Set thinking state
    final thinkingMsg = isEnglish
        ? 'AI Interviewer is analyzing your answer...'
        : 'AI 면접관이 답변을 분석 중입니다...';

    String statusMsg;
    if (round.isFollowUpActive) {
      if (_currentIndex >= _rounds.length - 1) {
        statusMsg =
            isEnglish ? 'Aggregating final results...' : '최종 결과를 집계 중입니다...';
      } else {
        statusMsg = isEnglish
            ? 'Thank you. Preparing next question...'
            : '답변 감사합니다.\n다음 면접 질문을 준비 중입니다.';
      }
    } else {
      statusMsg = thinkingMsg;
    }

    _setAiThinking(true, message: statusMsg);

    try {
      if (!round.isFollowUpActive) {
        // --- 1. Main Answer Submission ---
        round.mainAnswer = answerText;
        notifyListeners();

        final result = await _aiService.evaluateAnswer(
          question: round.mainQuestion,
          userAnswer: answerText,
          languageCode: languageCode,
        );

        round.mainGrade = result;

        if (result.followUpQuestion != null) {
          round.followUpQuestion = result.followUpQuestion;
        } else {
          await _moveToNext();
        }
      } else {
        // --- 2. Follow-Up Answer Submission ---
        round.followUpAnswer = answerText;
        notifyListeners();

        final result = await _aiService.evaluateAnswer(
          question: round.mainQuestion,
          userAnswer: answerText,
          previousFollowUp: round.followUpQuestion,
          languageCode: languageCode,
        );

        round.followUpGrade = result;
        await _moveToNext();
      }
    } catch (e) {
      print('Error submitting answer: $e');
      await _moveToNext();
    } finally {
      _setAiThinking(false);
    }
  }

  // Skip the current follow-up (Pass)
  Future<void> passFollowUp() async {
    if (currentRound == null || !currentRound!.isFollowUpActive) return;

    // Mark as skipped
    currentRound!.followUpAnswer = "[SKIPPED]";
    await _moveToNext();
  }

  Future<void> _moveToNext() async {
    _currentIndex++;
    notifyListeners();

    if (isSessionFinished) {
      await _saveSessionResults();
    }
  }

  Future<void> _saveSessionResults() async {
    if (_currentSessionId == null) return;

    try {
      double totalScore = 0;
      int count = 0;

      final sessionItems = _rounds.map((round) {
        // Calculate round score (average of main + follow-up if exists)
        // For MVP, just use main grade score.
        // If follow-up exists, maybe average them?
        // Let's stick to main grade for now or average both.

        final mainScore = round.mainGrade?.score ?? 0;
        totalScore += mainScore;
        count++;

        // Construct SessionQuestionItem
        return SessionQuestionItem(
          questionId: round.mainQuestion.id,
          questionText:
              round.mainQuestion.getLocalizedQuestion(_sessionLanguageCode),
          userAnswerText: round.mainAnswer ?? '',
          aiFollowUp: round.followUpQuestion,
          userFollowUpAnswer: round.followUpAnswer,
          evaluation: {
            'main': round.mainGrade?.toJson(),
            'followUp': round.followUpGrade?.toJson(),
          },
          subject: round.mainQuestion.subject,
          category:
              round.mainQuestion.getLocalizedCategory(_sessionLanguageCode),
        );
      }).toList();

      final averageScore = count > 0 ? totalScore / count : 0.0;

      await _repository.updateSession(
        sessionId: _currentSessionId!,
        data: {
          'status': 'completed',
          'endTime': Timestamp.now(),
          'averageScore': averageScore,
          'questions': sessionItems.map((i) => i.toJson()).toList(),
        },
      );

      print('[Session] Results saved successfully. Avg Score: $averageScore');
    } catch (e) {
      print('[Session] Failed to save results: $e');
    }
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
