class DailyCheckin {
  final String? id;
  final int mood;
  final String energy;
  final bool sleep;
  final String? summary;
  final DateTime? createdAt;

  DailyCheckin({
    this.id,
    required this.mood,
    required this.energy,
    required this.sleep,
    this.summary,
    this.createdAt,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['_id'],
      mood: json['mood'],
      energy: json['energy'],
      sleep: json['sleep'],
      summary: json['summary'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'energy': energy,
      'sleep': sleep,
    };
  }
}
