class Achievement {
  final String id;
  final String title;
  final String description;

  final String icon;

  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.icon == icon &&
        other.unlocked == unlocked &&
        other.unlockedAt == unlockedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, icon, unlocked, unlockedAt);

  @override
  String toString() => 'Achievement(id: $id, unlocked: $unlocked)';
}