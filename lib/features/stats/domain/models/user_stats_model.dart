class UserStats {
  final String uid;
  final int totalTrainings;
  final int averageScore; // Running average of all training scores

  UserStats({
    required this.uid,
    required this.totalTrainings,
    required this.averageScore,
  });

  factory UserStats.initial(String uid) {
    return UserStats(
      uid: uid,
      totalTrainings: 0,
      averageScore: 0,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] as String,
      totalTrainings: json['totalTrainings'] as int? ?? 0,
      averageScore: json['averageScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'totalTrainings': totalTrainings,
      'averageScore': averageScore,
    };
  }

  /// Create updated stats with a new training score.
  /// Uses cumulative moving average.
  UserStats withNewScore(int newScore) {
    final n = totalTrainings + 1;
    final newAvg = ((averageScore * totalTrainings) + newScore) / n;
    return UserStats(
      uid: uid,
      totalTrainings: n,
      averageScore: newAvg.round(),
    );
  }
}
