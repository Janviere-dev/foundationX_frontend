import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/features/auth/models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const _timeout = Duration(seconds: 20);

  Uri _url(String path) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    debugPrint('AuthService: $uri');
    return uri;
  }

  Future<String> _idToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError(
        'No signed-in Firebase user to authenticate the request with.',
      );
    }

    final token = await user.getIdToken(forceRefresh).timeout(_timeout);
    if (token == null) {
      throw StateError('Failed to obtain a Firebase ID token.');
    }

    return token;
  }

  Future<Map<String, String>> _headers({
    bool forceRefreshToken = false,
  }) async => {
    'Authorization':
        'Bearer ${await _idToken(forceRefresh: forceRefreshToken)}',
    'Content-Type': 'application/json',
  };

  Future<AppUser?> fetchProfile(String uid) async {
    final response = await http
        .get(
          _url('/api/users/me'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch profile (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromApi(data, photoUrl: _auth.currentUser?.photoURL);
  }

  AppUser partialProfileFor(User user) {
    final parts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final hasDisplayName = parts.isNotEmpty && parts.first.isNotEmpty;

    final firstName = hasDisplayName
        ? parts.first
        : _fallbackFirstName(user.email);
    final lastName = hasDisplayName && parts.length > 1
        ? parts.sublist(1).join(' ')
        : '';
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    return AppUser(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      provider: isGoogle ? 'google' : 'password',
    );
  }

  String _fallbackFirstName(String? email) {
    if (email == null || email.isEmpty) return 'Student';
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'Student';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  Future<void> createUser() async {
    final response = await http
        .post(
          _url('/api/users/create_user'),
          headers: await _headers(),
        )
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'AuthService.createUser: unexpected status ${response.statusCode}',
      );
    }
  }

  Future<AppUser> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName('$firstName $lastName'.trim());
    await user.sendEmailVerification();
    await createUser();

    return AppUser(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      photoUrl: user.photoURL,
      provider: 'password',
    );
  }

  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await createUser();
    return await fetchProfile(user.uid) ?? partialProfileFor(user);
  }

  Future<AppUser> signInWithGoogle() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    await createUser();

    return await fetchProfile(user.uid) ?? partialProfileFor(user);
  }

  Future<AppUser> saveProfile(AppUser profile) async {
    await _auth.currentUser?.reload();

    final body = {
      ...profile.toApiMap(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await http
        .put(
          _url('/api/users/extend_info'),
          headers: await _headers(forceRefreshToken: true),
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save profile (${response.statusCode})');
    }

    return profile;
  }

  /// Enrolls the signed-in user in [subject] (its catalog name, e.g.
  /// "Chemistry") via PATCH /api/users/subjects.
  Future<void> addSubject(String subject) async {
    final response = await http
        .patch(
          _url('/api/users/subjects'),
          headers: await _headers(),
          body: jsonEncode({'subject': subject}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to add subject (${response.statusCode})');
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resendEmailVerification() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to send a verification email to.');
    }
    return user.sendEmailVerification();
  }

  Future<bool> refreshEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
