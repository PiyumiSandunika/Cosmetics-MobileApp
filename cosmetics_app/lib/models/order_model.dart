import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status; // e.g., "Pending", "Shipped"
  final DateTime date;
  final List<Map<String, dynamic>> items; // List of product names/prices

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.date,
    required this.items,
  });

  // Convert Firebase data to Order object
  factory OrderModel.fromMap(Map<String, dynamic> data, String docId) {
    return OrderModel(
      id: docId,
      userId: data['userId'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      date: (data['date'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }

  // Convert Order object to Firebase data
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'total': total,
      'status': status,
      'date': Timestamp.fromDate(date),
      'items': items,
    };
  }
}