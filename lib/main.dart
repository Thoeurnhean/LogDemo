import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'homeScreen.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          //If it has error
          if (snapshot.hasError) {
            print('Error');
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return HomeScreen();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
