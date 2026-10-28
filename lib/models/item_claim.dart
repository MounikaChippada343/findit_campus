import 'package:cloud_firestore/cloud_firestore.dart';

class ItemClaim {
  final String claimId;
  final String itemId;
  final String claimantId;
  final String ownerId;
  final String message;
  final String status; // 'Pending', 'Accepted', 'Rejected', 'Completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemClaim({
    required this.claimId,
    required this.itemId,
    required this.claimantId,
    required this.ownerId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemClaim.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItemClaim(
      claimId: doc.id,
      itemId: data['itemId'] ?? '',
      claimantId: data['claimantId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'claimantId': claimantId,
      'ownerId': ownerId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}