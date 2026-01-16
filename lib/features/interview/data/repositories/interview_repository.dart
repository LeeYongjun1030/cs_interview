import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/question_model.dart';
import '../../domain/models/session_model.dart';

class InterviewRepository {
  final FirebaseFirestore _firestore;

  InterviewRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _questionsRef => _firestore.collection('questions');
  CollectionReference get _sessionsRef => _firestore.collection('sessions');

  Future<List<Question>> fetchQuestionsBySubject(String subject) async {
    try {
      final querySnapshot = await _questionsRef
          .where('subject', isEqualTo: subject)
          .get();

      return querySnapshot.docs
          .map((doc) => Question.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<List<Question>> fetchAllQuestions() async {
    try {
      // print('InterviewRepository: fetching collection "questions"');
      final querySnapshot = await _questionsRef.get();
      // print('InterviewRepository: got ${querySnapshot.docs.length} docs');
      return querySnapshot.docs
          .map((doc) => Question.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // print('InterviewRepository Error: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<String> createSession({
    required String userId,
    required String title,
    required List<Question> questions,
  }) async {
    try {
      // Create initial session items
      final sessionItems = questions.map((q) => SessionQuestionItem(
        questionId: q.id,
        questionText: q.question,
      )).toList();

      final session = InterviewSession(
        id: '', // Will be assigned by Firestore or UUID
        userId: userId,
        title: title,
        status: SessionStatus.active,
        startTime: DateTime.now(),
        questions: sessionItems,
      );

      // Add to Firestore and get ID
      final docRef = await _sessionsRef.add(session.toJson());
      
      // Update the local object ID if needed, but returning ID is usually enough
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<void> updateSessionItem(String sessionId, int index, SessionQuestionItem item) async {
    // This requires reading the array, modifying it, and updating back.
    // Or better, we map the entire questions list to JSON for updates.
    try {
        // Implement specific update logic depending on how granular we need to be.
        // For MVP, we might overwrite the 'questions' field.
        final sessionDoc = _sessionsRef.doc(sessionId);
        final snapshot = await sessionDoc.get();
        if (!snapshot.exists) throw Exception('Session not found');

        // final data = snapshot.data() as Map<String, dynamic>;
        // TODO: Implement proper update logic
        // For now, we are skipping full consistency update as it's MVP
        
        await sessionDoc.update({
          // Simple update logic placeholder
        });
        
        // However, since we don't have a fromJson on SessionQuestionItem easily in the snippet 
        // (it was manual), we should update the specific item in the array if possible 
        // OR just fetch the session, update local state, and save the session.
    } catch (e) {
       // ...
    }
  }
  Future<List<InterviewSession>> fetchUserSessions(String userId) async {
    try {
      final querySnapshot = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure ID is set from doc ID
            return InterviewSession.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user sessions: $e');
    }
  }
}
