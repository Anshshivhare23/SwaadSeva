import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService extends ChangeNotifier {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  AuthService() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);
      
      if (userData != null && token != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        _authToken = token;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String userType,
    required String serviceType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any email/password combination
      // In real implementation, this would be an actual API call
      if (email.isNotEmpty && password.length >= 6) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: _generateNameFromEmail(email),
          userType: userType,
          serviceType: serviceType,
          phone: '+91${DateTime.now().millisecondsSinceEpoch % 10000000000}',
          isVerified: true,
          createdAt: DateTime.now(),
        );

        const token = 'demo_auth_token_12345';
        
        _currentUser = user;
        _authToken = token;
        
        await _saveUserToStorage(user, token);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userType,
    required String serviceType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any valid input
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: name,
          userType: userType,
          serviceType: serviceType,
          phone: phone,
          isVerified: false, // Would need verification in real app
          createdAt: DateTime.now(),
        );

        const token = 'demo_auth_token_12345';
        
        _currentUser = user;
        _authToken = token;
        
        await _saveUserToStorage(user, token);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Please fill all required fields');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      
      _currentUser = null;
      _authToken = null;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isNotEmpty && email.contains('@')) {
        _setLoading(false);
        return true;
      } else {
        _setError('Please enter a valid email address');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _generateNameFromEmail(String email) {
    final username = email.split('@').first;
    return username.replaceAll(RegExp(r'[0-9._-]'), ' ').trim().split(' ')
        .map((word) => word.isNotEmpty ? 
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
        .join(' ');
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String userType;
  final String serviceType;
  final String phone;
  final bool isVerified;
  final DateTime createdAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? additionalData;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.serviceType,
    required this.phone,
    required this.isVerified,
    required this.createdAt,
    this.profileImageUrl,
    this.additionalData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      userType: json['userType'],
      serviceType: json['serviceType'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      profileImageUrl: json['profileImageUrl'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': userType,
      'serviceType': serviceType,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'additionalData': additionalData,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? userType,
    String? serviceType,
    String? phone,
    bool? isVerified,
    DateTime? createdAt,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      serviceType: serviceType ?? this.serviceType,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
