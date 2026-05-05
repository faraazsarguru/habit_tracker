import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': credential.user?.displayName ?? '',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return credential;
  }

  static Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> updateProfile({String? name}) async {
    final user = _auth.currentUser;
    if (user != null && name != null) {
      await user.updateDisplayName(name);
      await _db.collection('users').doc(user.uid).update({'name': name});
    }
  }
}
