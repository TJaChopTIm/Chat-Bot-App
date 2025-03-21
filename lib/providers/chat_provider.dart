import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatbotapp/apis/api_service.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static Future<void> initFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await UserModel.getUserFromFirestore(user.uid);
      await SettingsProvider().getSavedSettings(user.uid);
    }
  }
}

class ChatProvider extends ChangeNotifier {
  // list of messages
  final List<Message> _inChatMessages = [];

  // page controller
  final PageController _pageController = PageController();

  // images file list
  List<XFile>? _imagesFileList = [];

  // index of the current screen
  int _currentIndex = 0;

  // cuttent chatId
  String _currentChatId = '';

  // initialize generative model
  GenerativeModel? _model;

  // itialize text model
  GenerativeModel? _textModel;

  // initialize vision model
  GenerativeModel? _visionModel;

  // current mode
  String _modelType = 'gemini-pro';

  // loading bool
  bool _isLoading = false;

  // getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;

  List<XFile>? get imagesFileList => _imagesFileList;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }

      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timeSent', descending: false)
        .get();

    return messagesSnapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  }


  // set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // function to set the model based on bool - isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.0-flash'),
            apiKey: ApiService.apiKey,
          );
    } else {
      _model = _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.0-flash'),
            apiKey: ApiService.apiKey,
          );
    }
    notifyListeners();
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

//?Yeha bata copy

  Future<void> deleteChatMessages({required String chatId}) async {
    final batch = FirebaseFirestore.instance.batch();
    final messagesRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');

    final messages = await messagesRef.get();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(FirebaseFirestore.instance.collection('chat_history').doc(chatId));
    await batch.commit();
  }


  // prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      // 1.  load the chat messages from the db
      final chatHistory = await loadMessagesFromDB(chatId: chatID);

      // 2. clear the inChatMessages
      _inChatMessages.clear();

      for (var message in chatHistory) {
        _inChatMessages.add(message);
      }

      // 3. set the current chat id
      setCurrentChatId(newChatId: chatID);
    } else {
      // 1. clear the inChatMessages
      _inChatMessages.clear();

      // 2. set the current chat id
      setCurrentChatId(newChatId: chatID);
    }
  }

//?yeha samma

  // send message to gemini and get the streamed reposnse
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    // set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading
    setLoading(value: true);

    // get the chatId
    String chatId = getChatId();

    // list of history messages
    List<Content> history = await getHistory(chatId: chatId);

    // get the imagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

    // Tạo reference đến Firestore
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    // Lấy số lượng tin nhắn hiện có (để tạo ID mới)
    final messagesSnapshot = await messagesRef.get();
    final userMessageId = messagesSnapshot.docs.length;
    final assistantMessageId = userMessageId + 1;

    // user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // send the message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
    );
  }

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
  }) async {
    // start the chat session - only send history if it's text-only
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(
      message: message,
      isTextOnly: isTextOnly,
    );

    // assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      _inChatMessages
          .firstWhere((element) =>
      element.messageId == assistantMessage.messageId &&
          element.role.name == Role.assistant.name)
          .message
          .write(event.text);
      log('event: ${event.text}');
      notifyListeners();
    }, onDone: () async {
      log('stream done');
      // save message to Firestore
      await saveMessagesToDB(
        chatID: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
      );
      // set loading to false
      setLoading(value: false);
    }).onError((error, stackTrace) {
      log('error: $error');
      setLoading(value: false);
    });
  }

  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
  }) async {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatID);

    // Lưu tin nhắn user
    await chatRef.collection('messages').add(userMessage.toMap());
    // Lưu tin nhắn assistant
    await chatRef.collection('messages').add(assistantMessage.toMap());

    // 🔥 Cập nhật hoặc tạo mới lịch sử chat mà không ghi đè
    await FirebaseFirestore.instance.collection('chat_history').doc(chatID).set({
      'chatId': chatID,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'prompt': userMessage.message.toString(),
      'response': assistantMessage.message.toString(),
      'imagesUrls': userMessage.imagesUrls,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // 🔥 `merge: true` để không ghi đè dữ liệu cũ
  }


  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      // generate text from text-only input
      return Content.text(message);
    } else {
      // generate image from text and image input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // get y=the imagesUrls
  List<String> getImagesUrls({
    required bool isTextOnly,
  }) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }

    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }
}