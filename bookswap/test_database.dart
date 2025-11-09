import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/debug_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run debug tests
  await FirestoreDebugger.runDebugTests();
  
  // Check security rules
  await FirestoreDebugger.checkFirestoreRules();
}