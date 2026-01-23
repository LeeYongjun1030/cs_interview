class UserModel {
  final String uid;
  final String? email;
  final int credits;
  final DateTime? lastDailyBonus;

  UserModel({
    required this.uid,
    this.email,
    this.credits = 3, // Default 3 credits for new users
    this.lastDailyBonus,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'credits': credits,
      'lastDailyBonus': lastDailyBonus?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      credits: json['credits'] as int? ?? 5,
      lastDailyBonus: json['lastDailyBonus'] != null
          ? DateTime.parse(json['lastDailyBonus'] as String)
          : null,
    );
  }
}
