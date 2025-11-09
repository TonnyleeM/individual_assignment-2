import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';
import 'models/book_model.dart';
import 'services/firestore_service.dart';
import 'firebase_options.dart';

/// Debug script to test Firestore database structure
/// Run this to verify your database setup and troubleshoot issues
class FirestoreDebugger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirestoreService _firestoreService = FirestoreService();

  /// Initialize Firebase and run debug tests
  static Future<void> runDebugTests() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      print('🔥 Firebase initialized successfully');
      
      // Test 1: Check current user
      await _testCurrentUser();
      
      // Test 2: Test user profile creation
      await _testUserProfileCreation();
      
      // Test 3: Test book creation
      await _testBookCreation();
      
      // Test 4: List all users in database
      await _listAllUsers();
      
      // Test 5: List all books in database
      await _listAllBooks();
      
    } catch (e) {
      print('❌ Error during debug tests: $e');
    }
  }

  static Future<void> _testCurrentUser() async {
    print('\n📱 Testing Current User...');
    final user = _auth.currentUser;
    if (user != null) {
      print('✅ Current user: ${user.email} (${user.uid})');
      print('   Email verified: ${user.emailVerified}');
      print('   Display name: ${user.displayName}');
    } else {
      print('❌ No current user signed in');
    }
  }

  static Future<void> _testUserProfileCreation() async {
    print('\n👤 Testing User Profile Creation...');
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Cannot test user profile - no user signed in');
      return;
    }

    try {
      // Create a test user profile
      final userProfile = AppUser(
        id: user.uid,
        name: user.displayName ?? 'Test User',
        email: user.email ?? '',
        verified: user.emailVerified,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createOrUpdateUserProfile(userProfile);
      print('✅ User profile created/updated successfully');

      // Verify it was created
      final retrievedProfile = await _firestoreService.getUserProfile(user.uid);
      if (retrievedProfile != null) {
        print('✅ User profile retrieved successfully:');
        print('   Name: ${retrievedProfile.name}');
        print('   Email: ${retrievedProfile.email}');
        print('   Verified: ${retrievedProfile.verified}');
      } else {
        print('❌ Failed to retrieve user profile');
      }
    } catch (e) {
      print('❌ Error creating user profile: $e');
    }
  }

  static Future<void> _testBookCreation() async {
    print('\n📚 Testing Book Creation...');
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Cannot test book creation - no user signed in');
      return;
    }

    try {
      // Create a test book
      final testBook = BookModel(
        id: '', // Will be set by Firestore
        title: 'Test Book',
        author: 'Test Author',
        condition: 'Good',
        imageUrl: null,
        ownerId: user.uid,
        ownerName: user.displayName ?? 'Test User',
        status: 'available',
        createdAt: DateTime.now(),
      );

      final bookId = await _firestoreService.createBook(testBook);
      print('✅ Test book created with ID: $bookId');

      // Verify it was created
      final retrievedBook = await _firestoreService.getBookById(bookId);
      if (retrievedBook != null) {
        print('✅ Book retrieved successfully:');
        print('   Title: ${retrievedBook.title}');
        print('   Author: ${retrievedBook.author}');
        print('   Owner: ${retrievedBook.ownerName}');
        print('   Status: ${retrievedBook.status}');
      } else {
        print('❌ Failed to retrieve book');
      }
    } catch (e) {
      print('❌ Error creating book: $e');
    }
  }

  static Future<void> _listAllUsers() async {
    print('\n👥 Listing All Users in Database...');
    try {
      final snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isEmpty) {
        print('❌ No users found in database');
      } else {
        print('✅ Found ${snapshot.docs.length} users:');
        for (final doc in snapshot.docs) {
          final data = doc.data();
          print('   User ID: ${doc.id}');
          print('   Name: ${data['name'] ?? 'N/A'}');
          print('   Email: ${data['email'] ?? 'N/A'}');
          print('   Verified: ${data['verified'] ?? false}');
          print('   ---');
        }
      }
    } catch (e) {
      print('❌ Error listing users: $e');
    }
  }

  static Future<void> _listAllBooks() async {
    print('\n📖 Listing All Books in Database...');
    try {
      final snapshot = await _firestore.collection('books').get();
      if (snapshot.docs.isEmpty) {
        print('❌ No books found in database');
      } else {
        print('✅ Found ${snapshot.docs.length} books:');
        for (final doc in snapshot.docs) {
          final data = doc.data();
          print('   Book ID: ${doc.id}');
          print('   Title: ${data['title'] ?? 'N/A'}');
          print('   Author: ${data['author'] ?? 'N/A'}');
          print('   Owner: ${data['ownerName'] ?? 'N/A'}');
          print('   Status: ${data['status'] ?? 'N/A'}');
          print('   ---');
        }
      }
    } catch (e) {
      print('❌ Error listing books: $e');
    }
  }

  /// Check Firestore security rules
  static Future<void> checkFirestoreRules() async {
    print('\n🔒 Testing Firestore Security Rules...');
    try {
      // Test read access to users collection
      await _firestore.collection('users').limit(1).get();
      print('✅ Can read users collection');
    } catch (e) {
      print('❌ Cannot read users collection: $e');
    }

    try {
      // Test read access to books collection
      await _firestore.collection('books').limit(1).get();
      print('✅ Can read books collection');
    } catch (e) {
      print('❌ Cannot read books collection: $e');
    }
  }
}