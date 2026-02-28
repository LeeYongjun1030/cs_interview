class UserStats {
  final String uid;
  final int totalTrainings;
  final Map<String, int>
      stats; // 6-axis: summary, principle, example, keyword, clarity, followUp

  UserStats({
    required this.uid,
    required this.totalTrainings,
    required this.stats,
  });

  factory UserStats.initial(String uid) {
    return UserStats(
      uid: uid,
      totalTrainings: 0,
      stats: {
        'summary': 50, // 한 문장 요약(두괄식)
        'principle': 50, // 원리 설명
        'example': 50, // 예시/경험
        'keyword': 50, // 핵심 키워드
        'clarity': 50, // 흐름/명확성
        'followUp': 50, // 꼬리 질문 대응
      },
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] as String,
      totalTrainings: json['totalTrainings'] as int? ?? 0,
      stats: Map<String, int>.from(json['stats'] ??
          {
            'summary': 50,
            'principle': 50,
            'example': 50,
            'keyword': 50,
            'clarity': 50,
            'followUp': 50,
          }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'totalTrainings': totalTrainings,
      'stats': stats,
    };
  }

  /// Create updated stats by blending new evaluation scores.
  /// Uses exponential moving average: new = old * 0.7 + eval * 0.3
  UserStats withNewEvaluation(Map<String, int> evalScores) {
    final newStats = Map<String, int>.from(stats);
    for (final key in evalScores.keys) {
      final old = newStats[key] ?? 50;
      final incoming = evalScores[key] ?? 50;
      newStats[key] = ((old * 0.7) + (incoming * 0.3)).round();
    }
    return UserStats(
      uid: uid,
      totalTrainings: totalTrainings + 1,
      stats: newStats,
    );
  }
}
