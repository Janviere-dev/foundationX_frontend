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

  /// Builds an [AppUser] from the FastAPI backend's `GET /api/users/me`
  /// response (snake_case; onboarding fields absent until the
  /// complete-profile wizard has run, which is what keeps [isComplete]
  /// false for them). The backend doesn't store [photoUrl] - that comes
  /// from Firebase directly, since Firebase Auth already owns it.
  factory AppUser.fromApi(Map<String, dynamic> json, {String? photoUrl}) {
    final signInProvider = json['sign_in_provider'] as String?;

    return AppUser(
      uid: json['user_id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      school: json['school'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String? ?? 'Rather not say',
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photoUrl: photoUrl,
      provider: signInProvider == 'google.com' ? 'google' : 'password',
    );
  }

  /// Body for `PUT /api/users/extend_info`. Requires [dateOfBirth] to
  /// already be set - both call sites (completeProfile/updateProfile) only
  /// reach this once onboarding has collected a real date of birth.
  Map<String, dynamic> toApiMap() {
    assert(
      dateOfBirth != null,
      'dateOfBirth must be set before saving a profile to the backend',
    );

    return {
      'first_name': firstName,
      'last_name': lastName,
      'school': school,
      'grade': grade,
      'subjects': subjects,
      'goals': goals,
      'gender': gender,
      'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      'onboarding_complete': true,
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
