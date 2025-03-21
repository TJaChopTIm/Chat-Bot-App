import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isDarkMode => _isDarkMode;
  bool get shouldSpeak => _shouldSpeak;

  // Lấy cài đặt từ Firestore
  Future<void> getSavedSettings(String uid) async {
    final doc = await _firestore.collection('settings').doc(uid).get();
    if (doc.exists) {
      _isDarkMode = doc.data()?['isDarkMode'] ?? false;
      _shouldSpeak = doc.data()?['shouldSpeak'] ?? false;
    }
    notifyListeners();
  }

  // Cập nhật chế độ tối
  Future<void> toggleDarkMode(String uid, bool value) async {
    _isDarkMode = value;
    await _firestore.collection('settings').doc(uid).set({'isDarkMode': value}, SetOptions(merge: true));
    notifyListeners();
  }

  // Cập nhật chế độ giọng nói
  Future<void> toggleSpeak(String uid, bool value) async {
    _shouldSpeak = value;
    await _firestore.collection('settings').doc(uid).set({'shouldSpeak': value}, SetOptions(merge: true));
    notifyListeners();
  }
}
