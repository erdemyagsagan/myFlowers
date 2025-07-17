import 'package:flutter/material.dart';
import '../extensions/user_data.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Bilgileri'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Kullanıcı bilgilerini kaydetme
                await UserData.saveUserData(
                  _nameController.text,
                  _emailController.text,
                );
                Navigator.pop(context); // Geri gitmek için
              },
              child: const Text('Kaydet'),
            ),
            ElevatedButton(
              onPressed: () async {
                await UserData.clearUserData();
                await UserData.setLoggedIn(false);
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
