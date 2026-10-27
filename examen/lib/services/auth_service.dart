import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUser = 'saved_user';
  static const String _keyPass = 'saved_pass';
  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, username);
    await prefs.setString(_keyPass, password);
    await prefs.setBool(_keyIsLoggedIn, true);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString(_keyUser);
    final savedPass = prefs.getString(_keyPass);

    if (savedUser == username && savedPass == password) {
      await prefs.setBool(_keyIsLoggedIn, true);
      return true;
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  //Devuelve el usuario logueado
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return prefs.getString(_keyUser);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}