import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/app_icon.png', // ✅ Đường dẫn logo
                height: 100,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/login_icon.png',
                    height: 24,
                  ),
                  onPressed: () async {
                    await authProvider.signInWithEmail(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      context: context,
                    );
                  },
                  label: const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 24,
                  ),
                  label: const Text('Đăng nhập bằng Google'),
                  onPressed: () async {
                    await authProvider.signInWithGoogle(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Chưa có tài khoản? Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
