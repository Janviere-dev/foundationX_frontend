class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String school;
  final String grade;
  final List<String> subjects;
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
    this.photoUrl,
  });

  String get name => '$firstName $lastName'.trim();

  bool get isComplete =>
      school.isNotEmpty && grade.isNotEmpty && subjects.isNotEmpty;

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
      'photoUrl': photoUrl,
      'provider': provider,
    };
  }

  AppUser copyWith({
    String? school,
    String? grade,
    List<String>? subjects,
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
    );
  }
}