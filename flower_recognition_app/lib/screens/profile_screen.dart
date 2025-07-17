import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? email = prefs.getString('email');
    setState(() {
      _isLoggedIn = loggedIn;
      _userEmail = email;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _isLoggedIn = false;
      _userEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoggedIn
              ? SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(
                              'assets/images/profile_placeholder.jpg',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.camera_alt, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hoş geldin, $_userEmail',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuItem(
                      icon: Icons.home,
                      title: 'Ana Sayfa',
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Geçmiş',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Çıkış Yap',
                      onTap: _logout,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: LoginScreen(onLoginSuccess: _checkLoginStatus),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
