import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/screens/chat_screen.dart';
import 'package:chatbotapp/screens/profile_screen.dart';
import 'package:chatbotapp/screens/chat_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    int currentIndex = chatProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          ChatHistoryScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          chatProvider.setCurrentIndex(newIndex: index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
        ],
      ),
    );
  }
}
