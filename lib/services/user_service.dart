import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    } else {
      final newUser = UserModel(
        uid: user.uid,
        fullName: user.displayName ?? 'Campus User',
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      return newUser;
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    await _firestore.collection('users').doc(userModel.uid).update(userModel.toMap());
  }

  Future<Map<String, int>> getUserStats(String uid) async {
    final snapshot = await _firestore
        .collection('items')
        .where('ownerId', isEqualTo: uid)
        .get();

    int lostCount = 0;
    int foundCount = 0;
    int resolvedCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final type = (data['type'] ?? '').toString().toLowerCase();
      final status = (data['status'] ?? '').toString().toLowerCase();

      if (type == 'lost') lostCount++;
      if (type == 'found') foundCount++;
      if (status == 'resolved' || status == 'returned' || status == 'closed') {
        resolvedCount++;
      }
    }

    return {
      'lost': lostCount,
      'found': foundCount,
      'resolved': resolvedCount,
    };
  }

  // Added missing method
  Stream<List<Map<String, dynamic>>> getUserItemsStream(String uid) {
    return _firestore
        .collection('items')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}