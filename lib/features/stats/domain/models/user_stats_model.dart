class UserStats {
  final String uid;
  final int mmr;
  final String tier;
  final Map<String, int> stats; // logic, knowledge, defense, agility, structure

  UserStats({
    required this.uid,
    required this.mmr,
    required this.tier,
    required this.stats,
  });

  factory UserStats.initial(String uid) {
    return UserStats(
      uid: uid,
      mmr: 1000,
      tier: 'Silver', // Start at Silver
      stats: {
        'logic': 50,
        'knowledge': 50,
        'defense': 50,
        'agility': 50,
        'structure': 50,
      },
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] as String,
      mmr: json['mmr'] as int? ?? 1000,
      tier: json['tier'] as String? ?? 'Silver',
      stats: Map<String, int>.from(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'mmr': mmr,
      'tier': tier,
      'stats': stats,
    };
  }
}
