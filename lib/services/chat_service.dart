import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'notification_service.dart';
import '../services/chat_service.dart';
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Get or create a private chat room between two users for a specific item
  Future<String> getOrCreateChatRoom({
    required String currentUserId,
    required String otherUserId,
    required String itemId,
    required String itemTitle,
  }) async {
    // Check if chat room already exists for this item and participants
    final query = await _firestore
        .collection('chatRooms')
        .where('itemId', isEqualTo: itemId)
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in query.docs) {
      List participants = doc.data()['participants'] ?? [];
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat room if none exists
    final newRoomRef = await _firestore.collection('chatRooms').add({
      'participants': [currentUserId, otherUserId],
      'itemId': itemId,
      'itemTitle': itemTitle,
      'lastMessage': 'Chat started',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    return newRoomRef.id;
  }

  // Send a message in a chat room
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    required String itemTitle,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chatRooms')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update chat room last message
    await _firestore.collection('chatRooms').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    // Notify receiver
    await _notificationService.sendNotification(
      recipientId: receiverId,
      title: 'New Message about $itemTitle',
      message: text,
      type: 'chat',
    );
  }

  // Stream messages for a chat room
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Stream user chat rooms
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoom.fromMap(doc.data(), doc.id)).toList();
    });
  }
}