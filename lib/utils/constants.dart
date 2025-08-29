import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'SwaadSeva';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green for food/healthy
  static const Color secondaryColor = Color(0xFFFF9800); // Orange for warmth
  static const Color accentColor = Color(0xFF2196F3); // Blue for trust
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // User Types
  static const String userTypeCustomer = 'customer';
  static const String userTypeCook = 'cook';
  static const String userTypeDelivery = 'delivery';
  static const String userTypeAdmin = 'admin';
  
  // Dimensions
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Food Listing Duration
  static const int foodListingHours = 4;
  
  // Delivery Radius
  static const double deliveryRadiusKm = 7.0;
  
  // API Endpoints (will be updated later)
  static const String baseUrl = 'https://api.swaadseva.com';
}

class AppStrings {
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong!';
  static const String success = 'Success!';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String search = 'Search';
  
  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String name = 'Full Name';
  static const String phone = 'Phone Number';
  
  // User Types
  static const String customer = 'Customer';
  static const String homeCook = 'Home Cook';
  static const String deliveryBoy = 'Delivery Partner';
  static const String admin = 'Admin';
  
  // Service Types
  static const String tiffinDelivery = 'HOME-COOKED TIFFIN DELIVERY';
  static const String cookOnCall = 'COOK-ON-CALL';
  static const String tiffinService = 'Tiffin Service';
  static const String cookService = 'Cook Service';
  
  // Service Descriptions
  static const String tiffinDescription = 'Order delicious homemade tiffins delivered to your doorstep';
  static const String cookDescription = 'Book a cook to prepare fresh meals at your location';
  
  // Food Related
  static const String availableNow = 'Available Now';
  static const String orderNow = 'Order Now';
  static const String addToCart = 'Add to Cart';
  static const String viewMenu = 'View Menu';
  static const String riceAndRoti = 'Rice & Roti';
  static const String sabziOfTheDay = 'Sabzi of the Day';
  
  // Location
  static const String currentLocation = 'Current Location';
  static const String selectLocation = 'Select Location';
  static const String withinKm = 'within 7 km';
}
