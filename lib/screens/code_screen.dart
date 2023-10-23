import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oasis_forms_checker/main.dart';

class CodePage extends StatefulWidget {
  const CodePage({super.key});

  @override
  State<CodePage> createState() => CodePageState();
}

class CodePageState extends State<CodePage> {
  final TextEditingController codeController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  bool error = false;
  void displayError() {
    setState(() {
      error = true;
    });
  }

  // firestore code
  String code = 'soon to come';
  @override
  void initState() {
    super.initState();
    getCodeFromFirestore();
  }

  Future<void> getCodeFromFirestore() async {
    final DocumentReference codeDoc =
        FirebaseFirestore.instance.collection('phrase').doc('oasisPhrase');

    DocumentSnapshot snapshot = await codeDoc.get();
    if (snapshot.exists) {
      final String fetchedCode = snapshot['code'];
      setState(() {
        code = fetchedCode;
      });
    } else {
      print('no code');
    }
  }

  Future<void> _updateUserVerification() async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      await ref.update({'isVerified': true});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/oasisL.png', height: 100),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Enter security phrase to continue',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: codeController,
                          decoration: const InputDecoration(
                            hintText: 'Security phrase',
                            helperText:
                                'Note: Reach out if you did not receive it from Oasis.',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Visibility(
                          visible: error,
                          child: const Text(
                            'Incorrect Phrase',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (codeController.text == code) {
                              _updateUserVerification();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(
                                    title: 'Yay, I did it!',
                                    verified: true,
                                  ),
                                ),
                              );
                            } else {
                              displayError();
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
