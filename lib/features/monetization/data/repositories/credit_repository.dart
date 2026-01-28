import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import 'package:flutter/foundation.dart';

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
        if (!snapshot.exists) return false;

        final currentCredits = snapshot.get('credits') as int? ?? 0;

        // Check hard limit
        if (currentCredits >= MAX_CREDITS) return false;

        // Cap update to MAX_CREDITS if adding amount would exceed it?
        // Rules say: request...credits <= 50.
        // So we strictly ensure we don't exceed 50.
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
  Future<bool> claimDailyBonus(String uid) async {
    final docRef = _usersRef.doc(uid);
    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false; // Should exist if getUser called

        final data = snapshot.data() as Map<String, dynamic>;

        // 1. Check Max Credit Limit
        final currentCredits = data['credits'] as int? ?? 0;
        if (currentCredits >= MAX_CREDITS) return false;

        final lastBonusStr = data['lastDailyBonus'] as String?;
        final lastBonus =
            lastBonusStr != null ? DateTime.parse(lastBonusStr) : null;
        final now = DateTime.now();

        // Check if already claimed today
        if (lastBonus != null) {
          final isSameDay = lastBonus.year == now.year &&
              lastBonus.month == now.month &&
              lastBonus.day == now.day;
          if (isSameDay) return false;
        }

        transaction.update(docRef, {
          'credits': currentCredits + 1,
          'lastDailyBonus': now.toIso8601String(),
        });
        return true;
      });
    } catch (e) {
      debugPrint('CreditRepository: claimDailyBonus error: $e');
      return false;
    }
  }
}
