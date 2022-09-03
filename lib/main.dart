import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_canteens/screens/admin_homepage.dart';
import 'package:college_canteens/screens/authenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'screens/user_homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      initialRoute: '/init',
      routes: {
        '/auth': (context) => Authenticate(),
        '/init': (context) => InitializerWidget()
      },
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  FirebaseAuth? _auth;
  User? _user;
  bool isLoading = true;
  bool isAdmin = false;
  Map usrdata = {};

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth!.currentUser;
    route().then((value) => isLoading = false);
  }

  Future<void> route() async {
    if (_user == null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
    } else {
      var user = FirebaseFirestore.instance
          .doc('Users/${_auth!.currentUser!.phoneNumber}');
      DocumentSnapshot user_data = await user.get();
      setState(() {
        usrdata = user_data.data() as Map<String, dynamic>;
        usrdata['username'] = _auth!.currentUser!.phoneNumber;
        if (!usrdata['isAdmin']) {
        } else {
          isAdmin = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              title: const Text("Bolt Snack"),
            ),
            body: const Center(child: CircularProgressIndicator()),
          )
        : isAdmin
            ? AdminHomePage()
            : UserHomePage(
                usrdata: usrdata,
              );
  }
}
