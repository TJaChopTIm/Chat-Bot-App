import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/bottom_chat_field.dart';
import 'package:chatbotapp/widgets/chat_messages.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late String chatId; // ✅ Lưu chatId

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Lấy chatId từ arguments khi mở từ Chat History
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      chatId = args;
    } else {
      chatId = ''; // Nếu không có chatId, tạo mới
    }

    // ✅ Gọi prepareChatRoom() để load dữ liệu chat cũ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.prepareChatRoom(isNewChat: chatId.isEmpty, chatID: chatId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Trò chuyện cùng AI'),
            actions: [
              if (chatProvider.inChatMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.add),
                      onPressed: () async {
                        // ✅ Khi bắt đầu chat mới, tạo chatId mới
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Start New Chat',
                          content: 'Are you sure you want to start a new chat?',
                          actionText: 'Yes',
                          onActionPressed: (value) async {
                            if (value) {
                              await chatProvider.prepareChatRoom(
                                  isNewChat: true, chatID: '');
                              setState(() {
                                chatId = ''; // Reset chatId để tạo mới
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? const Center(
                      child: Text('No messages yet'),
                    )
                        : ChatMessages(
                      scrollController: _scrollController,
                      chatProvider: chatProvider,
                    ),
                  ),
                  BottomChatField(chatProvider: chatProvider)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
