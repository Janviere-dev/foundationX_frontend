import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/features/auth/models/app_user.dart';
import 'package:foundationx_frontend/features/auth/services/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._userProvider) {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  final UserProvider _userProvider;
  late final StreamSubscription<User?> _authSubscription;

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;
  bool needsProfileCompletion = false;
  bool needsEmailVerification = false;

  /// Reacts to Firebase's own auth state, which is what catches a session
  /// restored on app launch — nobody calls login()/register() for that, so
  /// without this, needsProfileCompletion would stay at its default false
  /// and the router could send an unfinished profile straight to /home.
  /// Explicit sign-in flows below set status to loading before they touch
  /// Firebase, so this bails out and lets them finish instead of racing —
  /// that race (this listener resolving before the explicit flow's own
  /// Firestore read) is what caused a fresh Google sign-up to jump straight
  /// to /home instead of the complete-profile wizard.
  Future<void> _onAuthStateChanged(User? user) async {
    debugPrint(
      'AuthProvider._onAuthStateChanged: uid=${user?.uid} status=$status',
    );
    if (status == AuthStatus.loading) return;

    if (user == null) {
      needsProfileCompletion = false;
      needsEmailVerification = false;
      status = AuthStatus.idle;
      notifyListeners();
      return;
    }

    status = AuthStatus.loading;
    notifyListeners();

    try {
      final profile =
          await _authService.fetchProfile(user.uid) ??
              _authService.partialProfileFor(user);
      _applyProfile(profile);
    } catch (_) {
      status = AuthStatus.idle;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final profile = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      _applyProfile(profile);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_messageForCode(e.code));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final profile = await _authService.registerWithEmail(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      _applyProfile(profile);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_messageForCode(e.code));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final profile = await _authService.signInWithGoogle();
      _applyProfile(profile);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        status = AuthStatus.idle;
        notifyListeners();
        return false;
      }
      _setError('Google sign-in failed. Please try again.');
      return false;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _setError('Google sign-in failed. Please try again.');
      return false;
    }
  }

  /// Called from the last step of the complete-profile wizard (subject +
  /// goals selection), once every onboarding field has been collected.
  /// Writes the full profile to Firestore in one go.
  Future<bool> completeProfile({
    required String school,
    required String grade,
    required DateTime dateOfBirth,
    required String gender,
    required List<String> subjects,
    required List<String> goals,
  }) async {
    _setLoading();
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw StateError('No signed-in user to complete a profile for.');
      }

      final current = _userProvider.user;
      final providerId = firebaseUser.providerData.isNotEmpty
          ? firebaseUser.providerData.first.providerId
          : 'password';

      final profile = AppUser(
        uid: firebaseUser.uid,
        firstName: current.firstName,
        lastName: current.lastName,
        email: current.email,
        school: school,
        grade: grade,
        subjects: subjects,
        dateOfBirth: dateOfBirth,
        gender: gender,
        goals: goals,
        photoUrl: firebaseUser.photoURL,
        provider: providerId == 'google.com' ? 'google' : 'password',
      );

      final saved = await _authService.saveProfile(profile);
      _applyProfile(saved);
      return true;
    } catch (_) {
      _setError('Could not save your profile. Please try again.');
      return false;
    }
  }

  /// Called from Edit Profile (Settings) to update school/grade/subjects/
  /// goals after onboarding is already complete. Reuses saveProfile since
  /// it's the same "write the full profile" operation as completeProfile,
  /// just triggered later and with different fields editable.
  Future<bool> updateProfile({
    required String school,
    required String grade,
    required List<String> subjects,
    required List<String> goals,
  }) async {
    _setLoading();
    try {
      final current = _userProvider.user;

      final profile = AppUser(
        uid: current.id,
        firstName: current.firstName,
        lastName: current.lastName,
        email: current.email,
        school: school,
        grade: grade,
        subjects: subjects,
        dateOfBirth: current.dateOfBirth,
        gender: current.gender,
        goals: goals,
        photoUrl: FirebaseAuth.instance.currentUser?.photoURL,
        provider: FirebaseAuth.instance.currentUser?.providerData
                    .any((p) => p.providerId == 'google.com') ==
                true
            ? 'google'
            : 'password',
      );

      final saved = await _authService.saveProfile(profile);
      _applyProfile(saved);
      return true;
    } catch (_) {
      _setError('Could not update your profile. Please try again.');
      return false;
    }
  }

  /// Sends a "reset your password" email. Doesn't sign anyone in - status
  /// goes back to idle on success, not authenticated.
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      status = AuthStatus.idle;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_messageForCode(e.code));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> resendVerificationEmail() async {
    _setLoading();
    try {
      await _authService.resendEmailVerification();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_messageForCode(e.code));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  /// Called from the "I've verified, continue" button - re-checks Firebase
  /// since emailVerified only updates locally after an explicit reload.
  Future<bool> refreshEmailVerification() async {
    final verified = await _authService.refreshEmailVerified();
    needsEmailVerification = !verified;
    notifyListeners();
    return verified;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    status = AuthStatus.idle;
    needsProfileCompletion = false;
    needsEmailVerification = false;
    notifyListeners();
  }

  void _applyProfile(AppUser profile) {
    needsProfileCompletion = !profile.isComplete;
    needsEmailVerification =
        FirebaseAuth.instance.currentUser?.emailVerified == false;
    _userProvider.applyAuthProfile(profile);
    status = AuthStatus.authenticated;
    debugPrint(
      'AuthProvider._applyProfile: uid=${profile.uid} '
      'firstName="${profile.firstName}" lastName="${profile.lastName}" '
      'school="${profile.school}" grade="${profile.grade}" '
      'subjects=${profile.subjects} isComplete=${profile.isComplete} '
      '-> needsProfileCompletion=$needsProfileCompletion '
      'needsEmailVerification=$needsEmailVerification',
    );
    notifyListeners();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    status = AuthStatus.error;
    errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}