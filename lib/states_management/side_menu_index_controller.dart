import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SideMenuIndexController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _currentIndexSelected = 0;
  bool _isMenuVisible = true;
  int _unreadNotificationCount = 0;

  StreamSubscription<int>? _notificationStreamSubscription;

  int get selectedIndex => _selectedIndex;
  int get currentIndexSelected => _currentIndexSelected;
  bool get isMenuVisible => _isMenuVisible;
  int get unreadNotificationCount => _unreadNotificationCount;

  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  /// Updates the page index and notifies listeners
  void updatePageIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Sets the selected index and notifies listeners
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Sets the current selected index and notifies listeners
  void setCurrentSelectedIndex(int index) {
    _currentIndexSelected = index;
    notifyListeners();
  }

  /// Toggles the visibility of the side menu
  void toggleMenuVisibility() {
    _isMenuVisible = !_isMenuVisible;
    notifyListeners();
  }

  /// Initializes the notification stream listener
  void initializeNotificationStream() {
    _notificationStreamSubscription =
        getUnreadNotificationCountStream().listen((notificationCount) {
      _unreadNotificationCount = notificationCount;
      notifyListeners();
    });
  }

  /// Cancels the notification stream subscription when no longer needed
  @override
  void dispose() {
    _notificationStreamSubscription?.cancel();
    super.dispose();
  }

  /// Returns a stream that tracks the unread notification count
  Stream<int> getUnreadNotificationCountStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
