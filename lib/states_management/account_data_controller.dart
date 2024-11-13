import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDataController extends ChangeNotifier {
  bool _isLoggedIn = false;

  String? _currentUserName;
  String? get currentUserName => _currentUserName;

  String? _currentUserEmail;
  String? get currentEmail => _currentUserEmail;

  String? _currentUserContactNumber;
  String? get currentUserContactNumber => _currentUserContactNumber;

  AccountDataController() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserName = prefs.getString('currentUserName');
    _currentUserEmail = prefs.getString('currentEmail');
    _currentUserContactNumber = prefs.getString('currentUserContactNumber');
    _isLoggedIn = _currentUserName != null &&
        _currentUserEmail != null &&
        _currentUserContactNumber != null;
    notifyListeners();
  }

  Future<void> _saveUserData({
    String? userName,
    String? userEmail,
    String? userContactNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) await prefs.setString('currentUserName', userName);
    if (userEmail != null) await prefs.setString('currentEmail', userEmail);
    if (userContactNumber != null) {
      await prefs.setString('currentUserContactNumber', userContactNumber);
    }
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<void> setUserData({
    String? userName,
    String? userEmail,
    String? userContactNumber,
  }) async {
    _currentUserName = userName;
    _currentUserEmail = userEmail;
    _currentUserContactNumber = userContactNumber;
    _isLoggedIn =
        userName != null && userEmail != null && userContactNumber != null;

    // Save user data and load it immediately after saving
    await _saveUserData(
      userName: userName,
      userEmail: userEmail,
      userContactNumber: userContactNumber,
    );
    await _loadUserData(); // Load user data after saving

    notifyListeners();
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    _isLoggedIn = loggedIn;
    if (!loggedIn) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUserName');
      await prefs.remove('currentEmail');
      await prefs.remove('currentUserContactNumber');
    }
    notifyListeners();
  }
}
