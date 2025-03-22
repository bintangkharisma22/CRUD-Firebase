import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:biodata1/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBjouBN_d3P8iUsWJkQNPai2XbAEU3OJyk",
        authDomain: "biodata-c0c51.firebaseapp.com",
        projectId: "biodata-c0c51",
        storageBucket: "biodata-c0c51.firebasestorage.app",
        messagingSenderId: "808504019220",
        appId: "1:808504019220:web:9f4c988a130a1d8c0f1a01",
        measurementId: "G-BT2PDMGP85"
      )
    );
  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}
