import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Stream<List<Map<String, dynamic>>> getItemsStream() {
    return _firestore.collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Accepts dynamic so it works with both Map or LostFoundItem.toMap()
  Future<void> createItem(dynamic itemData) async {
    final Map<String, dynamic> dataMap = itemData is Map<String, dynamic> 
        ? itemData 
        : (itemData.toMap ? itemData.toMap() : Map<String, dynamic>.from(itemData));

    final docRef = await _firestore.collection('items').add(dataMap);
    
    if ((dataMap['type'] ?? '').toString().toLowerCase() == 'found') {
      await _notificationService.checkAndNotifyLostItemMatches(
        foundItemId: docRef.id,
        title: dataMap['title'] ?? '',
        category: dataMap['category'] ?? '',
        location: dataMap['location'] ?? '',
      );
    }
  }

  Future<void> reportItem(Map<String, dynamic> itemData) async {
    await createItem(itemData);
  }

  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  Future<void> markItemAsReturned(String itemId, String ownerId, String itemTitle) async {
    await _firestore.collection('items').doc(itemId).update({
      'status': 'Returned to Owner',
    });

    await _notificationService.sendNotification(
      recipientId: ownerId,
      title: 'Item Returned!',
      message: 'Your item "$itemTitle" has been marked as returned to owner.',
      type: 'return',
      itemId: itemId,
    );
  }
}