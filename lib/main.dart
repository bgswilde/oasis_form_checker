import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:oasis_forms_checker/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oasis_forms_checker/screens/code_screen.dart';
import 'package:oasis_forms_checker/screens/search_screen.dart';
import 'package:oasis_forms_checker/services/cloud_func_getters.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String client = '';

  @override
  void initState() {
    super.initState();
    getCloudFunctionValue('getGoogleClient', 'gClient').then((value) {
      setState(() {
        client = value;
      });
    });
  }

  Future<Widget> checkVerificationAndRedirect(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('isVerified')) {
        return MyHomePage(
            title: 'Verified returned', verified: data['isVerified']);
      } else {
        // Handle the case where 'isVerified' field is missing.
        return const MyHomePage(
            title: 'Not Verified yet, no field', verified: false);
      }
    } else {
      // Handle the case where the user document doesn't exist.
      return const MyHomePage(
          title: 'Not Verified Yet, no user', verified: false);
    }
  }

  void _checkAndCreateUserRecord(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // User doesn't exist in Firestore; create a user record
      try {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'isVerified': false,
        });
      } catch (e) {
        print(e);
      }
    }
  }


  @override
  Widget build(BuildContext context) {    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        // User is not signed in
        if (user == null) {
          List<ProviderConfiguration> providerConfigs = [EmailProviderConfiguration()];
          if (client != null) {
            providerConfigs.add(GoogleProviderConfiguration(clientId: client));
          }
          return SignInScreen(
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  action == AuthAction.signIn
                      ? 'To check Oasis student form submissions, sign in or register if this is your first time at this page.'
                      : 'Please register for an account to continue to check your student form submissions',
                ),
              );
            },
            sideBuilder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/oasisOL.png', width: 250, height: 250, fit: BoxFit.contain,),
                ),
              );
            },
            headerBuilder: (context, constraints, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/oasisL.png', width: 250, fit: BoxFit.contain,),
                ),
              );
            },
            providerConfigs: providerConfigs,
          );
        } else {
          _checkAndCreateUserRecord(user);
          return FutureBuilder<Widget>(
            future: checkVerificationAndRedirect(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data ??
                    const MyHomePage(title: 'Fallback', verified: false);
              } else {
                return const LoadingIndicator(
                    size: 100.0,
                    borderWidth: 5.0,
                    color: Color.fromARGB(255, 114, 82, 255));
              }
            },
          );
        }
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // maybe later check on switching to cupertino?
    return MaterialApp(
      title: 'Oasis Form Checker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 33, 40, 45)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.verified});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final bool verified;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> people = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _addRandomName() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      people.add('this person $_counter');
    });
  }

  void _authenticated() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      people.add('this person $_counter');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (widget.verified) {
      return SearchPage();
    } else {
      return const CodePage();
    }
  }
}
