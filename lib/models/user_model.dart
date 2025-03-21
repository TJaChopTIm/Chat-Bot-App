import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String image;

  UserModel({
    required this.uid,
    required this.name,
    required this.image,
  });

  // Chuyển đổi từ JSON để đọc dữ liệu từ Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
    );
  }

  // Chuyển đổi sang JSON để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'image': image,
    };
  }

  // Lưu user vào Firestore
  static Future<void> saveUserToFirestore(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap());
  }

  // Lấy user từ Firestore
  static Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
