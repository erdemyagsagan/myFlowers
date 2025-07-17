import 'package:flutter/material.dart';
import '../connections/database_integrated.dart';
import '../screens/profile_screen.dart'; // Profil ekranına yönlendirme için

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _message = ''; // Hata mesajlarını gösterecek
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Kayıt işlemi
  void _signup() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Gerekli alanları kontrol et
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _message = 'Lütfen tüm alanları doldurun.';
      });
      return;
    }

    // Şifre ve şifre tekrarı eşleşiyor mu kontrol et
    if (password != confirmPassword) {
      setState(() {
        _message = 'Şifreler uyuşmuyor!';
      });
      return;
    }

    // Veritabanına kullanıcıyı kaydet
    final userExists = await _databaseHelper.getUserByEmail(email);
    if (userExists != null) {
      setState(() {
        _message = 'Bu email ile kayıtlı bir kullanıcı var.';
      });
      return;
    }

    // Yeni kullanıcıyı kaydet
    final result = await _databaseHelper.insertUser({
      'email': email,
      'password': password,
    });

    if (result > 0) {
      setState(() {
        _message = 'Kayıt başarılı!';
      });

      // Kayıt olduktan sonra profil ekranına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ), // Profil ekranına yönlendirme
      );
    } else {
      setState(() {
        _message = 'Kayıt oluşturulamadı, lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Şifre Tekrarı',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: const Text('Kayıt Ol')),
            const SizedBox(height: 12),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
