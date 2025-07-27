import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_listing_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItem {
  final String itemName;
  final String itemDescription;
  final double itemPrice;
  final int quantity;
  final String? specialInstructions;

  OrderItem({
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    this.quantity = 1,
    this.specialInstructions,
  });

  factory OrderItem.fromFoodItem(FoodItem foodItem, {int quantity = 1, String? specialInstructions}) {
    return OrderItem(
      itemName: foodItem.name,
      itemDescription: foodItem.description,
      itemPrice: foodItem.price,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      itemPrice: map['itemPrice']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
      specialInstructions: map['specialInstructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }

  double get totalPrice => itemPrice * quantity;
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;
  
  final String cookId;
  final String cookName;
  final String cookPhone;
  final String cookAddress;
  final double cookLatitude;
  final double cookLongitude;
  
  final String? deliveryBoyId;
  final String? deliveryBoyName;
  final String? deliveryBoyPhone;
  
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  
  final OrderStatus status;
  final String? statusNote;
  final DateTime orderTime;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.cookId,
    required this.cookName,
    required this.cookPhone,
    required this.cookAddress,
    required this.cookLatitude,
    required this.cookLongitude,
    this.deliveryBoyId,
    this.deliveryBoyName,
    this.deliveryBoyPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.statusNote,
    required this.orderTime,
    this.confirmedAt,
    this.readyAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      customerLatitude: data['customerLatitude']?.toDouble() ?? 0.0,
      customerLongitude: data['customerLongitude']?.toDouble() ?? 0.0,
      cookId: data['cookId'] ?? '',
      cookName: data['cookName'] ?? '',
      cookPhone: data['cookPhone'] ?? '',
      cookAddress: data['cookAddress'] ?? '',
      cookLatitude: data['cookLatitude']?.toDouble() ?? 0.0,
      cookLongitude: data['cookLongitude']?.toDouble() ?? 0.0,
      deliveryBoyId: data['deliveryBoyId'],
      deliveryBoyName: data['deliveryBoyName'],
      deliveryBoyPhone: data['deliveryBoyPhone'],
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: data['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: data['deliveryFee']?.toDouble() ?? 0.0,
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      statusNote: data['statusNote'],
      orderTime: (data['orderTime'] as Timestamp).toDate(),
      confirmedAt: data['confirmedAt'] != null ? (data['confirmedAt'] as Timestamp).toDate() : null,
      readyAt: data['readyAt'] != null ? (data['readyAt'] as Timestamp).toDate() : null,
      pickedUpAt: data['pickedUpAt'] != null ? (data['pickedUpAt'] as Timestamp).toDate() : null,
      deliveredAt: data['deliveredAt'] != null ? (data['deliveredAt'] as Timestamp).toDate() : null,
      cancelledAt: data['cancelledAt'] != null ? (data['cancelledAt'] as Timestamp).toDate() : null,
      cancellationReason: data['cancellationReason'],
      rating: data['rating']?.toDouble(),
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerLatitude': customerLatitude,
      'customerLongitude': customerLongitude,
      'cookId': cookId,
      'cookName': cookName,
      'cookPhone': cookPhone,
      'cookAddress': cookAddress,
      'cookLatitude': cookLatitude,
      'cookLongitude': cookLongitude,
      'deliveryBoyId': deliveryBoyId,
      'deliveryBoyName': deliveryBoyName,
      'deliveryBoyPhone': deliveryBoyPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'statusNote': statusNote,
      'orderTime': Timestamp.fromDate(orderTime),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get statusDisplayText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed by Cook';
      case OrderStatus.preparing:
        return 'Being Prepared';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get isCompleted {
    return status == OrderStatus.delivered || status == OrderStatus.cancelled;
  }
}
