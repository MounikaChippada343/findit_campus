import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a notification to a specific user
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    String? itemId,
  }) async {
    final notification = NotificationModel(
      id: '',
      recipientId: recipientId,
      title: title,
      message: message,
      type: type,
      itemId: itemId,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('notifications').add(notification.toMap());
  }

  // Stream notifications for the logged-in user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  // Check for matching lost items when a found item is posted[cite: 2]
  Future<void> checkAndNotifyLostItemMatches({
    required String foundItemId,
    required String title,
    required String category,
    required String location,
  }) async {
    final lostItemsSnapshot = await _firestore
        .collection('items')
        .where('type', isEqualTo: 'lost')
        .get();

    for (var doc in lostItemsSnapshot.docs) {
      final data = doc.data();
      final ownerId = data['ownerId'];
      final lostTitle = (data['title'] ?? '').toString().toLowerCase();
      final lostCategory = (data['category'] ?? '').toString().toLowerCase();

      // Keyword and category match comparison[cite: 2]
      if (ownerId != null &&
          (lostTitle.contains(title.toLowerCase()) || title.toLowerCase().contains(lostTitle)) &&
          lostCategory == category.toLowerCase()) {
        await sendNotification(
          recipientId: ownerId,
          title: 'Potential Match Found!',
          message: 'Someone may have found your lost item! Tap to view the listing.',
          type: 'match',
          itemId: foundItemId,
        );
      }
    }
  }
}