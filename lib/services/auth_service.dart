import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String userType, // 'parent' or 'child'
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'kidPoints': userType == 'child' ? 0 : null,
      });

      return result;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user type from Firestore
  static Future<String?> getUserType() async {
    try {
      if (currentUser == null) return null;
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['userType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Add child to parent's family
  static Future<bool> addChildToFamily({
    required String childEmail,
    required String childName,
  }) async {
    try {
      if (currentUser == null) return false;
      
      // Get parent data
      Map<String, dynamic>? parentData = await getUserData();
      if (parentData == null || parentData['userType'] != 'parent') {
        return false;
      }

      // Create child account
      UserCredential? childCredential = await signUp(
        email: childEmail,
        password: 'defaultPassword123', // Should be changed by child later
        name: childName,
        userType: 'child',
      );

      if (childCredential != null) {
        // Add child to parent's family
        await _firestore
            .collection('families')
            .doc(currentUser!.uid)
            .collection('children')
            .doc(childCredential.user!.uid)
            .set({
          'name': childName,
          'email': childEmail,
          'kidPoints': 0,
          'addedAt': FieldValue.serverTimestamp(),
        });

        return true;
      }
      return false;
    } catch (e) {
      print('Error adding child to family: $e');
      return false;
    }
  }

  // Get children for parent
  static Stream<QuerySnapshot> getChildren() {
    if (currentUser == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('families')
        .doc(currentUser!.uid)
        .collection('children')
        .snapshots();
  }
}

