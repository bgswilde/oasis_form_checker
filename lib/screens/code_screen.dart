import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutterfire_ui/firestore.dart';
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
      print('we have a code! $code');
    } else {
      print('i dont think so');
    }
  }

  Future<void> _updateUserVerification() async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      await ref.update({'isVerified': true});
      print('updated to verified');
    } catch (e) {
      print('something went wrong in update $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Verification')),
      body: Center(
        child: Container(
          width: double
              .infinity, // Expand the container to the maximum available width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(
                    maxWidth: 800), // Set a maximum width for the Card
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        const Text('Enter security phrase to continue',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        TextFormField(
                          controller: codeController,
                          decoration: const InputDecoration(
                              hintText: 'Security phrase',
                              helperText:
                                  'Note: Reach out if you did not recieve from Oasis.'),
                        ),
                        Visibility(
                          visible: error,
                          child: const Text('Incorrect Phrase',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (codeController.text == code) {
                              print('Yep, that matched');
                              _updateUserVerification();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyHomePage(
                                          title: 'Yay, I did it!',
                                          verified: true)));
                            } else {
                              print('Nope');
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
