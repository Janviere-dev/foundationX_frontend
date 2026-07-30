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

  /// Firebase ID tokens expire hourly and the SDK auto-refreshes them
  /// under the hood, so this is fetched fresh per request rather than
  /// cached on the service.
  Future<String> _idToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError(
        'No signed-in Firebase user to authenticate the request with.',
      );
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw StateError('Failed to obtain a Firebase ID token.');
    }

    return token;
  }

  Future<Map<String, String>> _headers() async => {
        'Authorization': 'Bearer ${await _idToken()}',
        'Content-Type': 'application/json',
      };

  /// 200 -> the stored backend profile. 404 -> no backend record exists
  /// yet for this uid (create_user was never called for them), which the
  /// caller treats the same as today's "no profile yet" case.
  Future<AppUser?> fetchProfile(String uid) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: await _headers(),
    );

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch profile (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromApi(data, photoUrl: _auth.currentUser?.photoURL);
  }

  /// Builds an identity-only profile (name/email, no school/grade/subjects)
  /// for a Firebase user with no backend record yet, deriving the sign-in
  /// provider from Firebase's own provider data. [AppUser.isComplete] is
  /// false on the result, which is what tells AuthProvider to route into
  /// the complete-profile wizard. Public because AuthProvider also uses
  /// this to resolve a session restored on app launch, not just the
  /// explicit sign-in flows below.
  AppUser partialProfileFor(User user) {
    final parts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final hasDisplayName = parts.isNotEmpty && parts.first.isNotEmpty;

    // Some Google accounts (freshly created ones especially) don't return
    // a display name at all. Falling back to the email's local-part keeps
    // the avatar/greeting from silently rendering blank.
    final firstName =
        hasDisplayName ? parts.first : _fallbackFirstName(user.email);
    final lastName =
        hasDisplayName && parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final isGoogle =
        user.providerData.any((p) => p.providerId == 'google.com');

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

  /// Tells the backend a Firebase-authenticated user exists so it can
  /// create its own record for them. Safe to call after every sign-in -
  /// it no-ops server-side if the user already exists.
  Future<void> createUser() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/users/create_user'),
      headers: await _headers(),
    );

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

  /// Signs in with Google. Returns the existing backend profile for a
  /// returning user, or an identity-only profile (see [partialProfileFor])
  /// for a first-time sign-in that still needs school/grade/subjects
  /// collected via [saveProfile].
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
    final body = {
      ...profile.toApiMap(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/users/extend_info'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save profile (${response.statusCode})');
    }

    return profile;
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

  /// Firebase doesn't push emailVerified changes to the local User object
  /// automatically after the link is clicked in another tab/device -
  /// reload() re-fetches it from the server.
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
