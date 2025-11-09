import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

/// Utility to fix existing user profiles in Firestore
/// This will update any existing user documents to match the new structure
class UserProfileFixer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final AuthService _authService = AuthService();

  /// Fix all user profiles in the database
  static Future<void> fixAllUserProfiles() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      print('🔧 Starting user profile fix...');
      
      // Get all user documents
      final snapshot = await _firestore.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        print('❌ No user documents found');
        return;
      }
      
      print('📋 Found ${snapshot.docs.length} user documents to check');
      
      for (final doc in snapshot.docs) {
        await _fixUserDocument(doc);
      }
      
      print('✅ User profile fix completed');
      
    } catch (e) {
      print('❌ Error during user profile fix: $e');
    }
  }

  /// Fix a single user document
  static Future<void> _fixUserDocument(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('⚠️  Skipping document ${doc.id} - no data');
        return;
      }

      print('🔍 Checking user ${doc.id}...');
      
      // Check if document needs updating
      bool needsUpdate = false;
      Map<String, dynamic> updates = {};
      
      // Check for 'name' field (might be stored as 'displayName')
      if (!data.containsKey('name')) {
        if (data.containsKey('displayName')) {
          updates['name'] = data['displayName'];
          needsUpdate = true;
          print('  📝 Adding name field from displayName');
        } else {
          updates['name'] = 'User'; // Default name
          needsUpdate = true;
          print('  📝 Adding default name field');
        }
      }
      
      // Check for 'verified' field (might be stored as 'emailVerified')
      if (!data.containsKey('verified')) {
        if (data.containsKey('emailVerified')) {
          updates['verified'] = data['emailVerified'];
          needsUpdate = true;
          print('  📝 Adding verified field from emailVerified');
        } else {
          updates['verified'] = false; // Default to false
          needsUpdate = true;
          print('  📝 Adding default verified field');
        }
      }
      
      // Ensure email field exists
      if (!data.containsKey('email') || data['email'] == null || data['email'] == '') {
        print('  ⚠️  Missing email field for user ${doc.id}');
        // You might want to get this from Firebase Auth if available
      }
      
      // Ensure createdAt field exists
      if (!data.containsKey('createdAt')) {
        updates['createdAt'] = FieldValue.serverTimestamp();
        needsUpdate = true;
        print('  📝 Adding createdAt field');
      }
      
      // Apply updates if needed
      if (needsUpdate) {
        await doc.reference.update(updates);
        print('  ✅ Updated user ${doc.id}');
      } else {
        print('  ✅ User ${doc.id} already has correct structure');
      }
      
    } catch (e) {
      print('  ❌ Error fixing user ${doc.id}: $e');
    }
  }

  /// Create user profile for current authenticated user if it doesn't exist
  static Future<void> ensureCurrentUserProfile() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return;
      }
      
      print('👤 Checking profile for current user: ${user.email}');
      
      // Check if user document exists
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print('📝 Creating new user profile...');
        
        // Create new user profile
        final userProfile = AppUser(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          verified: user.emailVerified,
          createdAt: DateTime.now(),
        );
        
        await _authService.createOrUpdateUserProfile(userProfile);
        print('✅ User profile created successfully');
      } else {
        print('✅ User profile already exists');
        
        // Fix the existing profile if needed
        await _fixUserDocument(doc);
      }
      
    } catch (e) {
      print('❌ Error ensuring user profile: $e');
    }
  }
}

/// Run this function to fix your user profiles
void main() async {
  // Fix all existing user profiles
  await UserProfileFixer.fixAllUserProfiles();
  
  // Ensure current user has a proper profile
  await UserProfileFixer.ensureCurrentUserProfile();
}