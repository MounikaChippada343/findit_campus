import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
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

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.collegeName,
    required this.department,
    required this.yearOfStudy,
    required this.bio,
    required this.profileImageUrl,
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

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      collegeName: map['collegeName'] ?? '',
      department: map['department'] ?? '',
      yearOfStudy: map['yearOfStudy'] ?? '',
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      showCollege: map['showCollege'] ?? true,
      showDepartment: map['showDepartment'] ?? true,
      showYearOfStudy: map['showYearOfStudy'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? collegeName,
    String? department,
    String? yearOfStudy,
    String? bio,
    String? profileImageUrl,
    bool? showCollege,
    bool? showDepartment,
    bool? showYearOfStudy,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      collegeName: collegeName ?? this.collegeName,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      showCollege: showCollege ?? this.showCollege,
      showDepartment: showDepartment ?? this.showDepartment,
      showYearOfStudy: showYearOfStudy ?? this.showYearOfStudy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}