import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:foundationx_frontend/features/auth/models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  /// Builds an identity-only profile (name/email, no school/grade/subjects)
  /// for a Firebase user with no Firestore doc yet, deriving the sign-in
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
    return await fetchProfile(user.uid) ?? partialProfileFor(user);
  }

  /// Signs in with Google. Returns the existing Firestore profile for a
  /// returning user, or an identity-only profile (see [partialProfileFor])
  /// for a first-time sign-in that still needs school/grade/subjects
  /// collected via [saveProfile].
  Future<AppUser> signInWithGoogle() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    return await fetchProfile(user.uid) ?? partialProfileFor(user);
  }

  Future<AppUser> saveProfile(AppUser profile) async {
    await _usersRef.doc(profile.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

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