import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_claim.dart';

class ClaimService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitClaim(ItemClaim claim) async {
    await _firestore.collection('claims').doc(claim.claimId).set(claim.toMap());
  }

  Future<void> updateClaimStatus(String claimId, String status) async {
    await _firestore.collection('claims').doc(claimId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<ItemClaim>> getClaimsForUser(String userId) {
    return _firestore
        .collection('claims')
        .where('claimantId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ItemClaim.fromFirestore(doc)).toList());
  }

  Stream<List<ItemClaim>> getClaimsForOwnerItems(String ownerId) {
    return _firestore
        .collection('claims')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ItemClaim.fromFirestore(doc)).toList());
  }
}