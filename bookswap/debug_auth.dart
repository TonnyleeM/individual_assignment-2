import 'package:firebase_auth/firebase_auth.dart';

// Run this to check your auth status
void main() async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  
  if (user != null) {
    await user.reload();
    final updatedUser = auth.currentUser;
    print('User ID: ${updatedUser?.uid}');
    print('Email: ${updatedUser?.email}');
    print('Email Verified: ${updatedUser?.emailVerified}');
    print('Display Name: ${updatedUser?.displayName}');
  } else {
    print('No user signed in');
  }
}