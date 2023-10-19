import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CREATE USER
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle registration errors
      return null;
    }
  }

  // SIGN IN NORMAL
  Future<void> login(email, password) async {
    _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
