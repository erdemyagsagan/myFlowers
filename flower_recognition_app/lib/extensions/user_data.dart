import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static const String _keyName = 'userName';
  static const String _keyEmail = 'userEmail';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  static Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Kullanıcı bilgisini kaydetme
  static Future<void> saveUserData(String userName, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, userName);
    await prefs.setString(_keyEmail, email);
  }

  // Kullanıcı bilgilerini alma
  static Future<Map<String, String>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString(_keyName);
    String? email = prefs.getString(_keyEmail);

    return {
      'userName': userName ?? 'Bilinmiyor',
      'email': email ?? 'Bilinmiyor',
    };
  }

  // Kullanıcı bilgilerini silme
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
  }
}
