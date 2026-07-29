class UserModel {
  final String id, name, firstName, lastName, email, grade, school, username, gender;
  final int xpPoints, streak, level;
  final List<String> subjects;
  final List<String> goals;
  final DateTime? dateOfBirth;
  final DateTime? lastDailyQuiz;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    required this.school,
    this.firstName = '',
    this.lastName = '',
    this.username = 'Student',
    this.gender = 'Rather not say',
    this.xpPoints = 0,
    this.streak = 0,
    this.level = 1,
    this.subjects = const [],
    this.goals = const [],
    this.dateOfBirth,
    this.lastDailyQuiz,
  });

  bool get canTakeDailyQuiz {
    if (lastDailyQuiz == null) return true;
    return DateTime.now().difference(lastDailyQuiz!).inHours >= 24;
  }

 UserModel copyWith({
  DateTime? lastDailyQuiz,
  int? xpPoints,
  int? level,
  int? streak,
}) {
  return UserModel(
    id: id,
    name: name,
    firstName: firstName,
    lastName: lastName,
    email: email,
    grade: grade,
    school: school,
    username: username,
    gender: gender,
    subjects: subjects,
    goals: goals,
    dateOfBirth: dateOfBirth,
    xpPoints: xpPoints ?? this.xpPoints,
    streak: streak ?? this.streak,
    level: level ?? this.level,
    lastDailyQuiz: lastDailyQuiz ?? this.lastDailyQuiz,
  );
}
  }
