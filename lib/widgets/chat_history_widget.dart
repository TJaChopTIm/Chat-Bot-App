import 'package:flutter/material.dart';

class ChatHistoryWidget extends StatelessWidget {
  final String chatId;
  final String prompt;
  final String response;
  final DateTime? timestamp;

  const ChatHistoryWidget({
    super.key,
    required this.chatId,
    required this.prompt,
    required this.response,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          prompt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          response,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          timestamp != null
              ? "${timestamp!.day}/${timestamp!.month}/${timestamp!.year}"
              : "N/A",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: chatId, // ✅ Truyền chatId chính xác
          );
        },
      ),
    );
  }
}
