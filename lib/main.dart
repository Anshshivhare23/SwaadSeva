import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/service_selection_screen.dart';
import 'screens/auth/user_type_selection_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/cook/create_food_listing_screen.dart';
import 'screens/cook/my_listings_screen.dart';
import 'screens/customer/food_discovery_screen.dart';
import 'screens/customer/food_detail_screen.dart';
import 'services/firebase_auth_service.dart';
import 'models/food_listing_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseAuthService(),
      child: const SwaadSevaApp(),
    ),
  );
}

class SwaadSevaApp extends StatelessWidget {
  const SwaadSevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/service-selection': (context) => const ServiceSelectionScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/cook-dashboard': (context) => const DashboardScreen(),
        '/customer-dashboard': (context) => const DashboardScreen(),
        '/create-food-listing': (context) => const CreateFoodListingScreen(),
        '/my-listings': (context) => const MyListingsScreen(),
        '/food-discovery': (context) => const FoodDiscoveryScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/user-type-selection':
            final serviceType = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => UserTypeSelectionScreen(serviceType: serviceType),
            );
          case '/food-detail':
            final foodListing = settings.arguments as FoodListing;
            return MaterialPageRoute(
              builder: (context) => FoodDetailScreen(listing: foodListing),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}
