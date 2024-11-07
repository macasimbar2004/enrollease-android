import 'package:flutter/foundation.dart';

class SideMenuIndexController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _currentIndexSelected = 0;
  bool _isMenuVisible = true;

  int get selectedIndex => _selectedIndex;
  int get currentIndexSelected => _currentIndexSelected;
  bool get isMenuVisible => _isMenuVisible;

  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  void updatePageIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setCurrentSelectedIndex(int index) {
    _currentIndexSelected =
        index; // Update currentIndexSelected when the index is set
    notifyListeners();
  }

  void toggleMenuVisibility() {
    _isMenuVisible = !_isMenuVisible;
    notifyListeners();
  }
}
