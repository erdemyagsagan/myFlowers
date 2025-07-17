import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../connections/database_integrated.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _message = '';
  final _db = DatabaseHelper();

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    if (email.isEmpty || pwd.isEmpty) {
      setState(() => _message = 'Lütfen tüm alanları doldurun.');
      return;
    }
    final user = await _db.getUserByEmail(email);
    if (user == null || user['password'] != pwd) {
      setState(() => _message = 'Email veya şifre yanlış!');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "myFlowers",
          style: TextStyle(
            fontFamily: 'PlaywriteCU',
            fontSize: 26,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/myFlowersLogo.png', height: 140),
            const SizedBox(height: 24),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text('Giriş Yap', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            Text(_message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
              child: const Text('Hesabınız yoksa Kaydol'),
            ),
          ],
        ),
      ),
    );
  }
}
