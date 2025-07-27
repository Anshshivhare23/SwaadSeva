import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;

  FoodItem({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}

class FoodListing {
  final String id;
  final String cookId;
  final String cookName;
  final String cookPhone;
  final String? cookImageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final List<FoodItem> items;
  final String specialNote;
  final DateTime availableFrom;
  final DateTime availableUntil;
  final bool isActive;
  final double rating;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodListing({
    required this.id,
    required this.cookId,
    required this.cookName,
    required this.cookPhone,
    this.cookImageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
    this.specialNote = '',
    required this.availableFrom,
    required this.availableUntil,
    this.isActive = true,
    this.rating = 0.0,
    this.totalOrders = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodListing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FoodListing(
      id: doc.id,
      cookId: data['cookId'] ?? '',
      cookName: data['cookName'] ?? '',
      cookPhone: data['cookPhone'] ?? '',
      cookImageUrl: data['cookImageUrl'],
      address: data['address'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      specialNote: data['specialNote'] ?? '',
      availableFrom: (data['availableFrom'] as Timestamp).toDate(),
      availableUntil: (data['availableUntil'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      rating: data['rating']?.toDouble() ?? 0.0,
      totalOrders: data['totalOrders'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cookId': cookId,
      'cookName': cookName,
      'cookPhone': cookPhone,
      'cookImageUrl': cookImageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'items': items.map((item) => item.toMap()).toList(),
      'specialNote': specialNote,
      'availableFrom': Timestamp.fromDate(availableFrom),
      'availableUntil': Timestamp.fromDate(availableUntil),
      'isActive': isActive,
      'rating': rating,
      'totalOrders': totalOrders,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isAvailableNow {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(availableFrom) && 
           now.isBefore(availableUntil);
  }

  double get totalPrice {
    return items.where((item) => item.isAvailable)
                .fold(0.0, (total, item) => total + item.price);
  }

  FoodListing copyWith({
    String? id,
    String? cookId,
    String? cookName,
    String? cookPhone,
    String? cookImageUrl,
    String? address,
    double? latitude,
    double? longitude,
    List<FoodItem>? items,
    String? specialNote,
    DateTime? availableFrom,
    DateTime? availableUntil,
    bool? isActive,
    double? rating,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodListing(
      id: id ?? this.id,
      cookId: cookId ?? this.cookId,
      cookName: cookName ?? this.cookName,
      cookPhone: cookPhone ?? this.cookPhone,
      cookImageUrl: cookImageUrl ?? this.cookImageUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      items: items ?? this.items,
      specialNote: specialNote ?? this.specialNote,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
