import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart'; // Yeni profil ekranını dahil ettik
import '../extensions/user_data.dart'; // UserData import

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Başlangıçta Ana Sayfa (index 1) gösterilsin.

  final List<Widget> _pages = [
    const HistoryScreen(), // Geçmiş sayfası index 0
    const HomeScreen(), // Ana Sayfa index 1
    const ProfileScreen(), // Profil sayfası index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _pages[_currentIndex], // currentIndex'e göre doğru sayfa gösterilecek.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 2) {
            // Profil butonuna tıklanınca
            bool isLoggedIn = await UserData.isLoggedIn();
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              Navigator.pushNamed(context, '/login');
            }
          } else {
            setState(() {
              _currentIndex = index; // Geçerli indeksi güncelle
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
