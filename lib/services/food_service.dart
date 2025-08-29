import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_listing_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _foodListingsCollection =>
      _firestore.collection('food_listings');

  // Create a new food listing
  Future<String> createFoodListing(FoodListing listing) async {
    try {
      DocumentReference docRef = await _foodListingsCollection.add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create food listing: $e');
    }
  }

  // Update an existing food listing
  Future<void> updateFoodListing(String listingId, FoodListing listing) async {
    try {
      await _foodListingsCollection.doc(listingId).update(listing.toFirestore());
    } catch (e) {
      throw Exception('Failed to update food listing: $e');
    }
  }

  // Delete a food listing
  Future<void> deleteFoodListing(String listingId) async {
    try {
      await _foodListingsCollection.doc(listingId).delete();
    } catch (e) {
      throw Exception('Failed to delete food listing: $e');
    }
  }

  // Get food listings for a specific cook
  Stream<List<FoodListing>> getCookFoodListings(String cookId) {
    return _foodListingsCollection
        .where('cookId', isEqualTo: cookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodListing.fromFirestore(doc))
          .toList();
    });
  }

  // Get all available food listings (for customers)
  Stream<List<FoodListing>> getAvailableFoodListings() {
    return _foodListingsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      List<FoodListing> listings = snapshot.docs
          .map((doc) => FoodListing.fromFirestore(doc))
          .where((listing) => 
              listing.isActive && 
              listing.availableUntil.isAfter(now))
          .toList();
      
      // Sort by createdAt in memory to avoid complex index requirements
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  // Get food listings near a location (requires implementation)
  Stream<List<FoodListing>> getNearbyFoodListings({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  }) {
    // For now, get all available listings
    // TODO: Implement proper geolocation filtering
    return getAvailableFoodListings();
  }

  // Search food listings by food name or cook name
  Stream<List<FoodListing>> searchFoodListings(String query) {
    if (query.isEmpty) {
      return getAvailableFoodListings();
    }

    return _foodListingsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) => FoodListing.fromFirestore(doc))
          .where((listing) {
            final queryLower = query.toLowerCase();
            return listing.isActive &&
                listing.availableUntil.isAfter(now) &&
                (listing.cookName.toLowerCase().contains(queryLower) ||
                 listing.items.any((item) => 
                     item.name.toLowerCase().contains(queryLower) ||
                     item.description.toLowerCase().contains(queryLower)));
          })
          .toList();
    });
  }

  // Get a specific food listing by ID
  Future<FoodListing?> getFoodListingById(String listingId) async {
    try {
      DocumentSnapshot doc = await _foodListingsCollection.doc(listingId).get();
      if (doc.exists) {
        return FoodListing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get food listing: $e');
    }
  }

  // Toggle food listing active status
  Future<void> toggleListingStatus(String listingId, bool isActive) async {
    try {
      await _foodListingsCollection.doc(listingId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to toggle listing status: $e');
    }
  }

  // Update food item availability
  Future<void> updateFoodItemAvailability(String listingId, int itemIndex, bool isAvailable) async {
    try {
      FoodListing? listing = await getFoodListingById(listingId);
      if (listing != null) {
        List<FoodItem> updatedItems = List.from(listing.items);
        if (itemIndex >= 0 && itemIndex < updatedItems.length) {
          updatedItems[itemIndex] = FoodItem(
            name: updatedItems[itemIndex].name,
            description: updatedItems[itemIndex].description,
            price: updatedItems[itemIndex].price,
            imageUrl: updatedItems[itemIndex].imageUrl,
            isAvailable: isAvailable,
          );

          await _foodListingsCollection.doc(listingId).update({
            'items': updatedItems.map((item) => item.toMap()).toList(),
            'updatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update food item availability: $e');
    }
  }

  // Get current user's cook ID (helper method)
  String? getCurrentCookId() {
    return _auth.currentUser?.uid;
  }
}
