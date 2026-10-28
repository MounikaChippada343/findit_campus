import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String collegeName;
  final String department;
  final String yearOfStudy;
  final String bio;
  final String profileImageUrl;
  final bool showCollege;
  final bool showDepartment;
  final bool showYearOfStudy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.collegeName = '',
    this.department = '',
    this.yearOfStudy = '',
    this.bio = '',
    this.profileImageUrl = '',
    this.showCollege = true,
    this.showDepartment = true,
    this.showYearOfStudy = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'collegeName': collegeName,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'showCollege': showCollege,
      'showDepartment': showDepartment,
      'showYearOfStudy': showYearOfStudy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: map['uid'] ?? docId,
      fullName: map['fullName'] ?? 'Campus User',
      email: map['email'] ?? '',
      collegeName: map['collegeName'] ?? '',
      department: map['department'] ?? '',
      yearOfStudy: map['yearOfStudy'] ?? '',
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      showCollege: map['showCollege'] ?? true,
      showDepartment: map['showDepartment'] ?? true,
      showYearOfStudy: map['showYearOfStudy'] ?? true,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }
}