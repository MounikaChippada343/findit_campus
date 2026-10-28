import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String notificationId;
  final String recipientId;
  final String title;
  final String message;
  final String? relatedItemId;
  final String? relatedClaimId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.recipientId,
    required this.title,
    required this.message,
    this.relatedItemId,
    this.relatedClaimId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      notificationId: doc.id,
      recipientId: data['recipientId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      relatedItemId: data['relatedItemId'],
      relatedClaimId: data['relatedClaimId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'relatedItemId': relatedItemId,
      'relatedClaimId': relatedClaimId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}