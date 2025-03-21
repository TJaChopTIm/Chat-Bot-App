import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/widgets/chat_history_widget.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử trò chuyện')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('chat_history')
            .where('userId', isEqualTo: auth.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có lịch sử trò chuyện"));
          }

          final chatHistory = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatHistory.length,
            itemBuilder: (context, index) {
              final chat = chatHistory[index];

              return GestureDetector(
                onTap: () {
                  final chatProvider = context.read<ChatProvider>();
                  chatProvider.setCurrentChatId(newChatId: chat['chatId']);
                  chatProvider.setCurrentIndex(newIndex: 1); // ✅ Chuyển sang tab Chat
                  Navigator.pop(context); // ✅ Quay lại HomeScreen thay vì mở màn hình mới
                },
                child: ChatHistoryWidget(
                  chatId: chat['chatId'],
                  prompt: chat['prompt'],
                  response: chat['response'],
                  timestamp: chat['timestamp'] != null
                      ? (chat['timestamp'] as Timestamp).toDate()
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
