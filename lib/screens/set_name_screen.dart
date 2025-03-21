import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetNameScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  SetNameScreen({super.key});

  Future<void> saveName(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid)
          .update({'name': nameController.text});

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt tên của bạn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên")),
            ElevatedButton(
              onPressed: () => saveName(context),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
