import 'package:enrollease/dev.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDataController extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AccountDataController() {
    loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUser = UserModel(
      userName: prefs.getString('userName') ?? '',
      email: prefs.getString('email') ?? '',
      contactNumber: prefs.getString('contactNumber') ?? '',
      uid: prefs.getString('uid') ?? '',
      role: prefs.getString('role') ?? '',
      isActive: prefs.getBool('isActive') ?? false,
      profilePicLink: prefs.getString('profilePicLink') ?? '',
    );

    _isLoggedIn = _currentUser?.uid.isNotEmpty ?? false;

    dPrint('Loaded user data: ${_currentUser?.toMap()}');
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> setUserData(UserModel? user) async {
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('userName', user.userName);
      await prefs.setString('email', user.email);
      await prefs.setString('contactNumber', user.contactNumber);
      await prefs.setString('uid', user.uid);
      await prefs.setString('role', user.role);
      await prefs.setBool('isActive', user.isActive);

      _isLoggedIn = user.uid.isNotEmpty;

      await loadUserData();
      dPrint('User data saved and reloaded: ${_currentUser?.toMap()}');
    } catch (e) {
      dPrint('Error saving user data: $e');
    }
  }

  // Dynamically update specific fields in UserModel
  void updateUserLocal(Map<String, dynamic> updatedFields) {
    if (_currentUser != null) {
      final currentData = _currentUser!.toMap();

      updatedFields.forEach((key, value) {
        if (currentData.containsKey(key) && value != null) {
          currentData[key] = value;
        }
      });

      _currentUser = UserModel.fromMap(currentData);

      dPrint('Updated user data: ${_currentUser?.toMap()}');
      notifyListeners();
    }
  }

  // void updateUserLocal(Map<String, dynamic> updatedFields) {
  //   if (_currentUser != null) {
  //     final currentData = _currentUser!.toMap();

  //     updatedFields.forEach((key, value) {
  //       if (currentData.containsKey(key) && value != null) {
  //         currentData[key] = value;
  //       }
  //     });

  //     _currentUser = UserModel(
  //       name: currentData['name'] ?? _currentUser!.name,
  //       email: currentData['email'] ?? _currentUser!.email,
  //       contactNumber:
  //           currentData['contactNumber'] ?? _currentUser!.contactNumber,
  //       uid: currentData['uid'] ?? _currentUser!.uid,
  //       role: currentData['role'] ?? _currentUser!.role,
  //       isActive: currentData['isActive'] ?? _currentUser!.isActive,
  //     );

  //     dPrint('Updated user data: ${_currentUser!.toMap()}');
  //     notifyListeners();
  //   }
  // }

  // Set the login state
  Future<void> setLoggedIn(bool loggedIn) async {
    _isLoggedIn = loggedIn;
    if (!loggedIn) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userName');
      await prefs.remove('email');
      await prefs.remove('contactNumber');
      await prefs.remove('uid');
      await prefs.remove('role');
      await prefs.remove('isActive');
      _currentUser = null;
    }
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear user data
  void clearUserData() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
