import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/screens_controller.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/model/destinations.dart';
import 'package:enrollease/states_management/side_menu_index_controller.dart';
import 'package:enrollease/widgets/bottom_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagesController extends StatefulWidget {
  const PagesController({super.key});

  @override
  State<PagesController> createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController =
        PageController(initialPage: 0); // Start with the first page

    // Listen for changes in selectedIndex from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SideMenuIndexController>()
          .addListener(_onSelectedIndexChange);
    });
  }

  @override
  void dispose() {
    // Remove listener when the widget is disposed
    context
        .read<SideMenuIndexController>()
        .removeListener(_onSelectedIndexChange);
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
        pageController
            .jumpToPage(selectedIndex); // Jump directly for non-adjacent pages
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: (_) {}, // Block horizontal drag gestures
          child: Consumer<SideMenuIndexController>(
            builder: (context, sideMenuController, child) {
              return PageView(
                controller: pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe scrolling
                onPageChanged: (index) {
                  sideMenuController
                      .setSelectedIndex(index); // Update selected index
                },
                children: screens,
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
                String assetPath =
                    entry.value.assetPath; // Access the asset path property

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: BottomNavWidget(
                    assetPath: assetPath, // Pass the asset path
                    index: index,
                    currentIndex: sideMenuController.selectedIndex,
                    onPressed: (val) {
                      // Update selected index and trigger page transition
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
