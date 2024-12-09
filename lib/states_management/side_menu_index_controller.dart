import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void initializeNotificationStream(BuildContext context) {
    _notificationStreamSubscription = getUnreadNotificationCountStream(context).listen((notificationCount) {
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
  Stream<int> getUnreadNotificationCountStream(BuildContext context) {
    final userID = context.read<AccountDataController>().currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('notifications')
        .where(
          'type',
          isEqualTo: 'user',
        )
        .where(
          'uid',
          isEqualTo: userID,
        )
        .where(
          'isRead',
          isEqualTo: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
        );
  }
}
