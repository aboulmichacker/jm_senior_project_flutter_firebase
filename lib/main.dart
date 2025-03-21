import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jm_senior/auth/auth_check.dart';
import 'package:jm_senior/my_theme_data.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
  try {
    final String emulatorHost = '10.0.2.2';
    // final String deviceHost = '192.168.1.107';
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080); 
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
 }

  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myThemeData,
      debugShowCheckedModeBanner: false,
      home: const AuthCheck()
    );
  }
}
