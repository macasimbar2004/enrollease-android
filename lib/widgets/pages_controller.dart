import 'dart:async';

import 'package:enrollease/dev.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/pages/enrollments_page.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/model/destinations.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:enrollease/widgets/bottom_nav_widget.dart';
import 'package:enrollease/widgets/side_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enrollease/pages/home_page.dart';
import 'package:enrollease/pages/notification_page.dart';
import 'package:enrollease/pages/profile_page.dart';
import 'package:enrollease/pages/school_fees_page.dart';

class PagesController extends StatefulWidget {
  const PagesController({super.key});

  @override
  State<PagesController> createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {
  late SideMenuIndexController _sideMenuController; // Cached controller
  late final PageController pageController;
  late UserModel currentUser;
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();

  StreamSubscription<Map<String, dynamic>>? _userDataSubscription;

  String userName = '';
  String email = '';
  String role = '';
  String contactNumber = '';
  String uid = '';
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);

    // Cache the controller and add a listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sideMenuController = context.read<SideMenuIndexController>();
      _sideMenuController.addListener(_onSelectedIndexChange);
      _sideMenuController.initializeNotificationStream();
    });
    // Listen to user data changes
    _userDataSubscription = _authProvider.fetchAndListenToUserData().listen((userData) {
      if (mounted) {
        // Start loading
        final accountDataController = Provider.of<AccountDataController>(context, listen: false);
        accountDataController.setLoading(true);

        // Set user data
        final updatedUser = UserModel(
          userName: userData['userName'] ?? '',
          email: userData['email'] ?? '',
          contactNumber: userData['contactNumber'] ?? '',
          uid: userData['uid'] ?? '',
          role: userData['role'] ?? '',
          isActive: userData['isActive'] ?? false,
          profilePicLink: userData['profilePicLink'] ?? '',
        );

        setState(() {
          currentUser = updatedUser;
          userName = userData['userName'] ?? '';
          email = userData['email'] ?? '';
          role = userData['role'] ?? '';
          contactNumber = userData['contactNumber'] ?? '';
          uid = userData['uid'] ?? '';
          isActive = userData['isActive'] ?? false;
          dPrint('current data from saved: ${currentUser.toMap()}');
        });

        // Set user data in AccountDataController
        accountDataController.setUserData(currentUser);
        accountDataController.setLoading(false);

        // Debug print statements
        dPrint('username: ${currentUser.userName}, email: ${currentUser.email}, role: ${currentUser.role}, contact: ${currentUser.contactNumber}, uid: ${currentUser.uid}, active: ${currentUser.isActive}');
        dPrint('${currentUser.toMap()}');
      }
    });
  }

  @override
  void dispose() {
    _sideMenuController.removeListener(_onSelectedIndexChange);
    _userDataSubscription?.cancel(); // Cancel the subscription correctly
    pageController.dispose();
    super.dispose();
  }

  void _onSelectedIndexChange() {
    final selectedIndex = context.read<SideMenuIndexController>().selectedIndex;
    if (pageController.hasClients) {
      // Check if the selected index is adjacent or non-adjacent for smoother page transitions
      if ((pageController.page!.round() - selectedIndex).abs() == 1) {
        animatePage(selectedIndex); // Use animation for adjacent pages
      } else {
        pageController.jumpToPage(selectedIndex); // Jump directly for non-adjacent pages
      }
    }
  }

  void animatePage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context); // Initialize screen size

    return Scaffold(
      key: context.read<SideMenuDrawerController>().scaffoldKey,
      drawer: const SideMenuWidget(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: (_) {}, // Block horizontal drag gestures
          child: Consumer<SideMenuIndexController>(
            builder: (context, sideMenuController, child) {
              return PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe scrolling
                onPageChanged: (index) {
                  sideMenuController.setSelectedIndex(index); // Update selected index
                },
                children: [
                  const HomePage(),
                  EnrollmentsPage(uid: uid),
                  const SchoolFeesPage(),
                  NotificationPage(userId: uid),
                  ProfilePage(userId: uid),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(), // Place the nav bar here
    );
  }

  Widget buildBottomNavigationBar() {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: Container(
        height: AppSizes.blockSizeHorizontal * 18,
        decoration: const BoxDecoration(
          color: CustomColors.bottomNavColor,
        ),
        child: Consumer<SideMenuIndexController>(
          builder: (context, sideMenuController, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: bottomNavIcons.asMap().entries.map((entry) {
                int index = entry.key;
                String assetPath = entry.value.assetPath;

                // Dynamically get notification count for the specific index
                int notificationCount = (index == 3) ? sideMenuController.unreadNotificationCount : 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: BottomNavWidget(
                    assetPath: assetPath,
                    index: index,
                    currentIndex: sideMenuController.selectedIndex,
                    notificationCount: notificationCount, // Pass the notification count
                    onPressed: (val) {
                      sideMenuController.setSelectedIndex(val);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
