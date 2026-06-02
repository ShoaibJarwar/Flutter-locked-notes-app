import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUserId = 'userId';

  Future<void> saveLogin(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, userId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
  }

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    if (userId != null) {
      await prefs.setString('pin_$userId', pin);
    }
  }

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    if (userId != null) {
      return prefs.getString('pin_$userId');
    }
    return null;
  }
}
