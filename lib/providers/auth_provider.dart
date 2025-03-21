import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbotapp/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Đăng ký tài khoản với Email/Password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin user vào Firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: "",
        image: "",
      );
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());

      // Chuyển hướng đến trang đặt tên (kiểm tra context.mounted trước)
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/set_name');
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng nhập với Email/Password
  Future<String?> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Chuyển hướng đến Home (kiểm tra context.mounted trước)
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng nhập bằng Google
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Kiểm tra nếu user mới, lưu vào Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? "Người dùng",
          image: user.photoURL ?? "",
        );
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      }

      // Chuyển hướng đến Home (kiểm tra context.mounted trước)
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // Đăng xuất
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();

    // Chuyển hướng đến Login (kiểm tra context.mounted trước)
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
