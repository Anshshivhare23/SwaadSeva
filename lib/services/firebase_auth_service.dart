import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String userType;
  final String serviceType;
  final DateTime createdAt;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.userType,
    required this.serviceType,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data();
      if (data == null) {
        throw Exception('Document data is null');
      }
      
      final dataMap = data as Map<String, dynamic>;
      return User(
        id: doc.id,
        email: dataMap['email']?.toString() ?? '',
        name: dataMap['name']?.toString() ?? '',
        phone: dataMap['phone']?.toString(),
        userType: dataMap['userType']?.toString() ?? AppConstants.userTypeCustomer,
        serviceType: dataMap['serviceType']?.toString() ?? AppStrings.tiffinDelivery,
        createdAt: (dataMap['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        profileImageUrl: dataMap['profileImageUrl']?.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing Firestore document: $e');
      // Return a default user with the document ID
      return User(
        id: doc.id,
        email: '',
        name: 'User',
        phone: null,
        userType: AppConstants.userTypeCustomer,
        serviceType: AppStrings.tiffinDelivery,
        createdAt: DateTime.now(),
        profileImageUrl: null,
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'serviceType': serviceType,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      userType: json['userType'] ?? AppConstants.userTypeCustomer,
      serviceType: json['serviceType'] ?? AppStrings.tiffinDelivery,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'serviceType': serviceType,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }
}

class FirebaseAuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  FirebaseAuthService() {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged, onError: (error) {
      debugPrint('Auth state change error: $error');
    });
  }

  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    try {
      debugPrint('Auth state changed: ${firebaseUser?.uid ?? "signed out"}');
      
      if (firebaseUser != null) {
        // User is signed in, fetch user data from Firestore
        await _loadUserData(firebaseUser.uid);
      } else {
        // User is signed out
        _currentUser = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in auth state change handler: $e');
      // Don't throw here, just log the error
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      debugPrint('Loading user data for: $userId');
      
      // Add retry logic for Firestore operations
      DocumentSnapshot? userDoc;
      int retries = 3;
      
      while (retries > 0) {
        try {
          userDoc = await _firestore.collection('users').doc(userId).get();
          break; // Success, exit retry loop
        } catch (e) {
          retries--;
          debugPrint('Firestore read attempt failed (retries left: $retries): $e');
          if (retries == 0) rethrow;
          await Future.delayed(const Duration(milliseconds: 500)); // Brief delay before retry
        }
      }
      
      if (userDoc != null && userDoc.exists) {
        _currentUser = User.fromFirestore(userDoc);
        debugPrint('User data loaded from Firestore successfully');
      } else {
        // If user document doesn't exist in Firestore, create a default one
        debugPrint('User document not found in Firestore, creating default profile');
        await _createDefaultUserProfile(userId);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Create a minimal user profile as fallback
      await _createFallbackUserProfile(userId);
    }
  }
  
  Future<void> _createDefaultUserProfile(String userId) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final defaultUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: null,
          userType: AppConstants.userTypeCustomer,
          serviceType: AppStrings.tiffinDelivery,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(defaultUser.toFirestore());
        _currentUser = defaultUser;
        debugPrint('Default user profile created in Firestore');
      }
    } catch (firestoreError) {
      debugPrint('Failed to create default profile in Firestore: $firestoreError');
      await _createFallbackUserProfile(userId);
    }
  }
  
  Future<void> _createFallbackUserProfile(String userId) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'User',
        phone: null,
        userType: AppConstants.userTypeCustomer,
        serviceType: AppStrings.tiffinDelivery,
        createdAt: DateTime.now(),
      );
      debugPrint('Using fallback user profile due to Firestore error');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    String? expectedUserType,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      debugPrint('Attempting login for: ${email.trim()}');
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        debugPrint('Firebase login successful for: ${credential.user!.email}');
        
        // Don't wait for auth state change, load user data directly
        await _loadUserData(credential.user!.uid);
        
        // Validate user type if expected type is provided
        if (expectedUserType != null && _currentUser != null) {
          if (_currentUser!.userType != expectedUserType) {
            await logout(); // Sign out the user
            _setError('Invalid account type. Please use ${expectedUserType == AppConstants.userTypeCook ? 'cook' : 'customer'} login.');
            return false;
          }
        }
        
        debugPrint('Login completed successfully');
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception during login: ${e.code} - ${e.message}');
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String userType,
    required String serviceType,
  }) async {
    firebase_auth.UserCredential? credential;
    
    try {
      _setLoading(true);
      _setError(null);

      debugPrint('Starting registration for: ${email.trim()}');

      // Create Firebase user
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        debugPrint('Firebase user created successfully: ${credential.user!.uid}');
        
        try {
          // Update Firebase user profile first
          await credential.user!.updateDisplayName(name);
          debugPrint('Firebase user display name updated');

          // Create user document in Firestore with retry logic
          final user = User(
            id: credential.user!.uid,
            email: email.trim(),
            name: name.trim(),
            phone: phone?.trim(),
            userType: userType,
            serviceType: serviceType,
            createdAt: DateTime.now(),
          );

          debugPrint('Attempting to create Firestore document...');
          
          // Use set with merge to avoid conflicts
          await _firestore.collection('users').doc(credential.user!.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
          
          debugPrint('Firestore document created successfully');
          _currentUser = user;
          
          // Don't wait for auth state change, return success immediately
          return true;
          
        } catch (firestoreError) {
          debugPrint('Firestore error during registration: $firestoreError');
          
          // Create a minimal user object to continue
          _currentUser = User(
            id: credential.user!.uid,
            email: email.trim(),
            name: name.trim(),
            phone: phone?.trim(),
            userType: userType,
            serviceType: serviceType,
            createdAt: DateTime.now(),
          );
          
          debugPrint('Continuing with minimal user data due to Firestore error');
          return true;
        }
      }
      
      debugPrint('Firebase user creation returned null credential');
      return false;
      
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      _setError(_getAuthErrorMessage(e.code));
      return false;
      
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      _setError('Registration failed. Please try again.');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_currentUser == null) return false;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_currentUser!.id).update(updates);
        
        // Update local user data
        _currentUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: name ?? _currentUser!.name,
          phone: phone ?? _currentUser!.phone,
          userType: _currentUser!.userType,
          serviceType: _currentUser!.serviceType,
          createdAt: _currentUser!.createdAt,
          profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        );
        
        // Update Firebase user profile if name changed
        if (name != null) {
          await _firebaseAuth.currentUser?.updateDisplayName(name);
        }
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);

      if (_currentUser == null) return false;

      // Delete user document from Firestore
      await _firestore.collection('users').doc(_currentUser!.id).delete();
      
      // Delete Firebase user account
      await _firebaseAuth.currentUser?.delete();
      
      _currentUser = null;
      return true;
    } catch (e) {
      _setError('Failed to delete account. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utility method to handle orphaned Firebase users (exists in Auth but not Firestore)
  Future<bool> fixOrphanedUser({
    required String name,
    String? phone,
    required String userType,
    required String serviceType,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      debugPrint('Fixing orphaned user: ${firebaseUser.email}');

      // Update Firebase user profile
      await firebaseUser.updateDisplayName(name);

      // Create user document in Firestore
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: name.trim(),
        phone: phone?.trim(),
        userType: userType,
        serviceType: serviceType,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toFirestore());
      _currentUser = user;
      
      debugPrint('Orphaned user fixed successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to fix orphaned user: $e');
      return false;
    }
  }

  // Get the correct dashboard route based on user type
  String getDashboardRoute() {
    if (_currentUser == null) return '/';
    
    return _currentUser!.userType == AppConstants.userTypeCook 
        ? '/cook-dashboard' 
        : '/customer-dashboard';
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        debugPrint('Unhandled auth error code: $errorCode');
        return 'Authentication failed. Please try again.';
    }
  }
}
