import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import 'package:flutter/foundation.dart';

enum DailyBonusStatus { success, alreadyClaimed, maxCreditsReached, error }

class CreditRepository {
  final FirebaseFirestore _firestore;

  CreditRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int MAX_CREDITS = 50;

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Fetch user data. If not exists, create with default credits.
  Future<UserModel> getUser(String uid, {String? email}) async {
    try {
      final docRef = _usersRef.doc(uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        // Create new user
        final newUser = UserModel(uid: uid, email: email, credits: 3);
        await docRef.set(newUser.toJson());
        return newUser;
      }
    } catch (e) {
      debugPrint('CreditRepository: getUser error: $e');
      // Fallback for offline or error, return minimal user
      return UserModel(uid: uid, email: email, credits: 0);
    }
  }

  /// Get real-time user stream
  Stream<UserModel> getUserStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      // Return default if not exists (UI handles creation via getUser if needed, or we just show 0)
      return UserModel(uid: uid, email: '', credits: 0);
    });
  }

  /// Deduct 1 credit. Returns true if successful, false if insufficient.
  Future<bool> deductCredit(String uid) async {
    final docRef = _usersRef.doc(uid);
    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        final startCredits = snapshot.get('credits') as int? ?? 0;
        if (startCredits <= 0) return false;

        transaction.update(docRef, {'credits': startCredits - 1});
        return true;
      });
    } catch (e) {
      debugPrint('CreditRepository: deductCredit error: $e');
      return false;
    }
  }

  /// Add credits. Returns true if successful, false if max reached or error.
  Future<bool> addCredit(String uid, int amount) async {
    final docRef = _usersRef.doc(uid);
    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // Self-healing: If user doc is missing (e.g. initial creation failed),
          // create it now. Rule requires initial credits to be 3.
          // We then add the reward on top of that.
          final newUser = UserModel(uid: uid, email: '', credits: 3);
          transaction.set(docRef, newUser.toJson());

          // Apply the reward (amount)
          int newCredits = 3 + amount;
          if (newCredits > MAX_CREDITS) newCredits = MAX_CREDITS;

          transaction.update(docRef, {'credits': newCredits});
          return true;
        }

        final currentCredits = snapshot.get('credits') as int? ?? 0;

        // Check hard limit
        if (currentCredits >= MAX_CREDITS) return false;

        int newCredits = currentCredits + amount;
        if (newCredits > MAX_CREDITS) {
          newCredits = MAX_CREDITS;
        }

        transaction.update(docRef, {'credits': newCredits});
        return true;
      });
    } catch (e) {
      debugPrint('CreditRepository: addCredit error: $e');
      return false;
    }
  }

  /// Check and claim daily bonus (1 credit)
  Future<DailyBonusStatus> claimDailyBonus(String uid) async {
    final docRef = _usersRef.doc(uid);
    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists)
          return DailyBonusStatus.error; // Should exist if getUser called

        final data = snapshot.data() as Map<String, dynamic>;

        // 1. Check Max Credit Limit
        final currentCredits = data['credits'] as int? ?? 0;
        if (currentCredits >= MAX_CREDITS)
          return DailyBonusStatus.maxCreditsReached;

        final lastBonusStr = data['lastDailyBonus'] as String?;
        final lastBonus =
            lastBonusStr != null ? DateTime.parse(lastBonusStr) : null;
        final now = DateTime.now();

        // Check if already claimed today
        if (lastBonus != null) {
          final isSameDay = lastBonus.year == now.year &&
              lastBonus.month == now.month &&
              lastBonus.day == now.day;
          if (isSameDay) return DailyBonusStatus.alreadyClaimed;
        }

        transaction.update(docRef, {
          'credits': currentCredits + 1,
          'lastDailyBonus': now.toIso8601String(),
        });
        return DailyBonusStatus.success;
      });
    } catch (e) {
      debugPrint('CreditRepository: claimDailyBonus error: $e');
      return DailyBonusStatus.error;
    }
  }

  /// Delete user document (Full Account Deletion)
  Future<void> deleteUser(String uid) async {
    try {
      await _usersRef.doc(uid).delete();
    } catch (e) {
      debugPrint('CreditRepository: deleteUser error: $e');
      throw e;
    }
  }
}
