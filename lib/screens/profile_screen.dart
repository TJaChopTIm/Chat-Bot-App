import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/settings_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userImage = '';
  String userName = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
      context.read<SettingsProvider>().getSavedSettings(_auth.currentUser!.uid);
    });
  }

  // Lấy dữ liệu user từ Firestore
  void getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Người dùng';
          userImage = doc.data()?['image'] ?? '';
        });
      }
    }
  }

  // Đăng xuất người dùng
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>(); // ✅ Vẫn cần sử dụng

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {}, // ✅ Nếu không dùng chọn ảnh, có thể xoá GestureDetector
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userImage.isNotEmpty
                      ? NetworkImage(userImage) as ImageProvider
                      : const AssetImage('assets/images/user_icon.png'),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40.0),
            ListTile(
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: settingsProvider.isDarkMode,
                onChanged: (value) {
                  settingsProvider.toggleDarkMode(_auth.currentUser!.uid, value);
                },
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: signOut,
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
