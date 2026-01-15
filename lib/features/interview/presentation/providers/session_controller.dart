import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/question_model.dart';
import '../../data/repositories/interview_repository.dart';

class SessionController extends ChangeNotifier {
  final InterviewRepository _repository;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SessionController({InterviewRepository? repository}) 
      : _repository = repository ?? InterviewRepository();

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  List<Question> _currentQuestions = [];
  int _currentIndex = 0;
  
  Question? get currentQuestion => _currentQuestions.isNotEmpty && _currentIndex < _currentQuestions.length 
      ? _currentQuestions[_currentIndex] 
      : null;
      
  int get currentIndex => _currentIndex;
  int get totalQuestions => _currentQuestions.length;
  bool get isSessionFinished => _currentIndex >= _currentQuestions.length;

  Future<String> startNewSession(String userId, String title) async {
    print('SessionController: Starting new session for $userId');
    _setLoading(true);
    _currentIndex = 0;
    _currentQuestions = [];
    _currentSessionId = null;

    try {
      // 1. Fetch ALL Questions
      print('SessionController: Fetching all questions...');
      final allQuestions = await _repository.fetchAllQuestions();
      print('SessionController: Fetched ${allQuestions.length} questions.');

      if (allQuestions.isEmpty) {
        throw Exception('No questions available in database');
      }

      // 2. Select 3 Questions Randomly (Mixed levels)
      _currentQuestions = _selectRandomQuestions(allQuestions);
      print('SessionController: Selected ${_currentQuestions.length} questions.');

      // 3. Create Session in Firestore
      print('SessionController: Creating session in Firestore...');
      final sessionId = await _repository.createSession(
        userId: userId,
        title: title,
        questions: _currentQuestions,
      );
      print('SessionController: Session created with ID: $sessionId');
      
      _currentSessionId = sessionId;

      return sessionId;
    } catch (e) {
      print('SessionController Error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitAnswer(String answerText) async {
    if (_currentSessionId == null) return;
    
    // In a real app, we would update the Firestore document here with the user's answer.
    // For now, we'll just move to the next question.
    // await _repository.updateSessionItem(...);
    
    _currentIndex++;
    notifyListeners();
  }

  List<Question> _selectRandomQuestions(List<Question> allQuestions) {
    // Simple random selection of 3 questions for MVP
    final random = Random();
    final available = List<Question>.from(allQuestions);
    available.shuffle(random);
    return available.take(3).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
