import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/question_model.dart';
import '../../domain/models/session_model.dart';
import '../../../training/domain/models/training_session_model.dart';
import '../../../stats/domain/models/user_stats_model.dart';

class InterviewRepository {
  final FirebaseFirestore _firestore;

  InterviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _sessionsRef => _firestore.collection('sessions');
  CollectionReference get _trainingRef =>
      _firestore.collection('training_sessions');
  CollectionReference get _userStatsRef => _firestore.collection('user_stats');

  List<Question>? _cachedQuestions;

  Future<List<Question>> _loadLocalQuestions() async {
    if (_cachedQuestions != null) return _cachedQuestions!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/questions.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      _cachedQuestions =
          jsonList.map((json) => Question.fromJson(json)).toList();
      return _cachedQuestions!;
    } catch (e) {
      throw Exception('Failed to load local questions: $e');
    }
  }

  Future<List<Question>> fetchQuestionsBySubject(String subject) async {
    try {
      final allQuestions = await _loadLocalQuestions();
      return allQuestions.where((q) => q.subject == subject).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions by subject: $e');
    }
  }

  Future<List<Question>> fetchAllQuestions() async {
    try {
      return await _loadLocalQuestions();
    } catch (e) {
      throw Exception('Failed to fetch all questions: $e');
    }
  }

  // ======================================================================
  // LEGACY: Interview sessions (kept for backward compatibility)
  // ======================================================================

  Future<String> createSession({
    required String userId,
    required String title,
    required List<Question> questions,
  }) async {
    try {
      final sessionItems = questions
          .map((q) => SessionQuestionItem(
                questionId: q.id,
                questionText: q.question,
                subject: q.subject,
                category: q.category,
              ))
          .toList();

      final session = InterviewSession(
        id: '',
        userId: userId,
        title: title,
        status: SessionStatus.active,
        startTime: DateTime.now(),
        questions: sessionItems,
      );

      final docRef = await _sessionsRef.add(session.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<void> saveSession(InterviewSession session) async {
    try {
      await _sessionsRef.add(session.toJson());
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  Future<void> updateSession({
    required String sessionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (sessionId.isEmpty) return;
      await _sessionsRef.doc(sessionId).update(data);
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  Future<List<InterviewSession>> fetchUserSessions(String userId) async {
    try {
      final querySnapshot = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return InterviewSession.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user sessions: $e');
    }
  }

  Stream<List<InterviewSession>> getUserSessionsStream(String userId) {
    return _sessionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return InterviewSession.fromJson(data);
      }).toList();
    });
  }

  Future<void> deleteAllUserSessions(String userId) async {
    try {
      final querySnapshot =
          await _sessionsRef.where('userId', isEqualTo: userId).get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all sessions: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionsRef.doc(sessionId).delete();
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  // ======================================================================
  // TRAINING SESSIONS
  // ======================================================================

  Future<void> saveTrainingSession(TrainingSession session) async {
    try {
      await _trainingRef.add(session.toJson());
    } catch (e) {
      throw Exception('Failed to save training session: $e');
    }
  }

  Stream<List<TrainingSession>> getTrainingSessionsStream(String userId) {
    return _trainingRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TrainingSession.fromJson(data);
      }).toList();
    });
  }

  Future<List<TrainingSession>> fetchTrainingSessions(String userId) async {
    try {
      final querySnapshot = await _trainingRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TrainingSession.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch training sessions: $e');
    }
  }

  Future<void> deleteTrainingSession(String sessionId) async {
    try {
      await _trainingRef.doc(sessionId).delete();
    } catch (e) {
      throw Exception('Failed to delete training session: $e');
    }
  }

  /// Delete all training sessions for a user.
  Future<void> deleteAllTrainingSessions(String userId) async {
    try {
      final querySnapshot =
          await _trainingRef.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all training sessions: $e');
    }
  }

  /// Reset user stats back to initial values (all axes = 50).
  Future<void> resetUserStats(String userId) async {
    try {
      final initial = UserStats.initial(userId);
      await _userStatsRef.doc(userId).set(initial.toJson());
    } catch (e) {
      throw Exception('Failed to reset user stats: $e');
    }
  }

  // ======================================================================
  // USER STATS (6-axis radar)
  // ======================================================================

  Future<UserStats> getUserStats(String userId) async {
    try {
      final doc = await _userStatsRef.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = userId;
        return UserStats.fromJson(data);
      }
      // Create initial stats if not found
      final initial = UserStats.initial(userId);
      await _userStatsRef.doc(userId).set(initial.toJson());
      return initial;
    } catch (e) {
      return UserStats.initial(userId);
    }
  }

  Future<void> saveUserStats(UserStats stats) async {
    try {
      await _userStatsRef.doc(stats.uid).set(stats.toJson());
    } catch (e) {
      throw Exception('Failed to save user stats: $e');
    }
  }

  // ======================================================================
  // DAILY QUESTION SELECTION
  // ======================================================================

  /// Select today's question. Stable per day (same question all day).
  /// Prioritizes: untrained > least-reviewed > date-based pick.
  Future<Question> getDailyQuestion(String userId) async {
    final allQuestions = await _loadLocalQuestions();
    if (allQuestions.isEmpty) {
      throw Exception('No questions available');
    }

    // Date-based seed so the pick is stable for the entire day
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;

    try {
      // Get recently trained question IDs
      final recentSessions = await _trainingRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final trainedIds =
          recentSessions.docs.map((d) => d['questionId'] as String).toSet();

      // Find untrained questions first
      final untrained =
          allQuestions.where((q) => !trainedIds.contains(q.id)).toList();

      if (untrained.isNotEmpty) {
        // Sort for stability, then pick by date seed
        untrained.sort((a, b) => a.id.compareTo(b.id));
        return untrained[daySeed % untrained.length];
      }
    } catch (e) {
      // Firestore index may not exist yet; fallback
      print('getDailyQuestion fallback: $e');
    }

    // Fallback: deterministic daily pick from all questions
    final sorted = List<Question>.from(allQuestions)
      ..sort((a, b) => a.id.compareTo(b.id));
    return sorted[daySeed % sorted.length];
  }
}
