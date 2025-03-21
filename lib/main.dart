import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/auth_provider.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/screens/auth_wrapper.dart';
import 'package:chatbotapp/screens/login_screen.dart';
import 'package:chatbotapp/screens/register_screen.dart';
import 'package:chatbotapp/screens/set_name_screen.dart';
import 'package:chatbotapp/screens/home_screen.dart';
import 'package:chatbotapp/screens/profile_screen.dart';
import 'package:chatbotapp/screens/chat_history_screen.dart';
import 'package:chatbotapp/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()), // ✅ Đảm bảo có SettingsProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<SettingsProvider>().isDarkMode; // ✅ Sử dụng Provider đúng cách

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatBot App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/set_name': (context) => SetNameScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat_history': (context) => const ChatHistoryScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
