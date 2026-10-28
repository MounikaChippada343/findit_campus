import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
    );
  }
}

class ChatRoom {
  final String chatId;
  final List<String> participants;
  final String itemId;
  final String itemTitle;
  final String lastMessage;
  final DateTime? lastMessageTimestamp;

  ChatRoom({
    required this.chatId,
    required this.participants,
    required this.itemId,
    required this.itemTitle,
    required this.lastMessage,
    this.lastMessageTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp != null ? Timestamp.fromDate(lastMessageTimestamp!) : FieldValue.serverTimestamp(),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map, String docId) {
    return ChatRoom(
      chatId: docId,
      participants: List<String>.from(map['participants'] ?? []),
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: map['lastMessageTimestamp'] != null ? (map['lastMessageTimestamp'] as Timestamp).toDate() : null,
    );
  }
}