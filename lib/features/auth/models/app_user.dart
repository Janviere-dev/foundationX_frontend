class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String school;
  final String grade;
  final List<String> subjects;
  final DateTime? dateOfBirth;
  final String gender;
  final List<String> goals;
  final String? photoUrl;
  final String provider;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.provider,
    this.school = '',
    this.grade = '',
    this.subjects = const [],
    this.dateOfBirth,
    this.gender = 'Rather not say',
    this.goals = const [],
    this.photoUrl,
  });

  String get name => '$firstName $lastName'.trim();

  /// A profile only has school/grade/subjects/dateOfBirth/goals once the
  /// complete-profile wizard has been finished; until then it's
  /// identity-only (name/email), which is what AuthProvider uses to
  /// decide whether to route into that wizard. Gender always has a
  /// default, so it never blocks completeness on its own.
  bool get isComplete =>
      school.isNotEmpty &&
      grade.isNotEmpty &&
      subjects.isNotEmpty &&
      dateOfBirth != null &&
      goals.isNotEmpty;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      school: map['school'] as String? ?? '',
      grade: map['grade'] as String? ?? '',
      subjects: (map['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'] as String)
          : null,
      gender: map['gender'] as String? ?? 'Rather not say',
      goals: (map['goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photoUrl: map['photoUrl'] as String?,
      provider: map['provider'] as String? ?? 'password',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'school': school,
      'grade': grade,
      'subjects': subjects,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'goals': goals,
      'photoUrl': photoUrl,
      'provider': provider,
    };
  }

  AppUser copyWith({
    String? school,
    String? grade,
    List<String>? subjects,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? goals,
  }) {
    return AppUser(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      provider: provider,
      photoUrl: photoUrl,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      subjects: subjects ?? this.subjects,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      goals: goals ?? this.goals,
    );
  }
}
