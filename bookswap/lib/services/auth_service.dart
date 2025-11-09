import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user document in Firestore with correct structure
      final userDoc = AppUser(
        id: userCredential.user!.uid,
        name: displayName,
        email: email.trim(),
        verified: false, // Will be updated when email is verified
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set(userDoc.toFirestore());

      return userDoc;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out: ${e.toString()}';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Error sending verification email: ${e.toString()}';
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        // Get the updated user after reload
        final updatedUser = _auth.currentUser;
        return updatedUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user verification status
  Future<void> updateUserVerification(String uid, bool verified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verified': verified,
      });
    } catch (e) {
      print('Error updating user verification: $e');
    }
  }

  // Create or update user profile
  Future<void> createOrUpdateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw 'Error creating/updating user profile: ${e.toString()}';
    }
  }

  // Convert Firebase User to AppUser
  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      verified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
