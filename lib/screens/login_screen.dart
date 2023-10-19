import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty &&
                      passwordController.text.length > 6) {
                    login();
                  } else {
                    debugPrint('Email or password is invalid');
                  }
                },
                child: const Text('Login')),
            ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty &&
                      passwordController.text.length > 6) {
                    signup();
                  } else {
                    debugPrint('Email or password is invalid');
                  }
                },
                child: const Text('Signup')),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

  Future<void> signup() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }
}
