import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_colors.dart';

class AppSkeleton extends ConsumerStatefulWidget {
  const AppSkeleton({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends ConsumerState<AppSkeleton> {
  int get _currentIndex =>
      _locationToTabIndex(GoRouter.of(context).state.fullPath ?? '');
  DateTime? _lastPressedAt; // last time user pressed back

  int _locationToTabIndex(String location) {
    final index = location.indexOf('/', 1);
    return index > 0
        ? _tabs.indexWhere(
            (t) => t.initialLocation == location.substring(0, index),
          )
        : _tabs.indexWhere((t) => t.initialLocation == location);
  }

  bool _isNotMainScreen(String location) {
    return location != AppConstants.homeRoute &&
        location != AppConstants.waterScheduleRoute &&
        location != AppConstants.weatherClientRoute &&
        location != AppConstants.waterRoutineRoute;
  }

  static const List<TabItem> _tabs = [
    TabItem(
      icon: Assets.homeIcon,
      activeIcon: Assets.homeAIcon,
      label: 'Garden',
      initialLocation: AppConstants.homeRoute,
    ),
    TabItem(
      icon: Assets.waterScheduleIcon,
      activeIcon: Assets.waterScheduleAIcon,
      label: 'Schedule',
      initialLocation: AppConstants.waterScheduleRoute,
    ),
    TabItem(
      icon: Assets.weatherClientIcon,
      activeIcon: Assets.weatherClientAIcon,
      label: 'Weather',
      initialLocation: AppConstants.weatherClientRoute,
    ),
    TabItem(
      icon: Assets.waterRoutineIcon,
      activeIcon: Assets.waterRoutineAIcon,
      label: 'Routine',
      initialLocation: AppConstants.waterRoutineRoute,
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      context.replace(_tabs[index].initialLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: kIsWeb
          ? null
          : (didPop, result) {
              final now = DateTime.now();
              if (_lastPressedAt == null ||
                  now.difference(_lastPressedAt!) >
                      const Duration(seconds: 2)) {
                // first press or pressed after 2s
                _lastPressedAt = now;
                // context.showInfoSnackBar('Nhấn lại lần nữa để thoát');
                return; // don’t exit yet
              }
              SystemNavigator.pop(); // Exit the app
            },
      child: Scaffold(
        body: widget.child,
        floatingActionButton: ClipOval(
          child: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                // Add your action here
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:
            _isNotMainScreen(GoRouter.of(context).state.fullPath ?? '')
            ? null
            : AppBottomNavBar(
                tabs: _tabs,
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
              ),
      ),
    );
  }
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<TabItem> tabs;
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      borderColor: Colors.grey.shade300,
      borderWidth: 1,
      itemCount: tabs.length,
      tabBuilder: (int index, bool isActive) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              isActive ? tabs[index].activeIcon : tabs[index].icon,
              color: isActive ? AppColors.primary : AppColors.neutral200,
            ),
            Text(
              tabs[index].label,
              style: TextStyle(
                fontSize: 13,
                color: currentIndex == index
                    ? AppColors.primary
                    : AppColors.neutral200,
              ),
            ),
          ],
        );
      },
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.defaultEdge,
      onTap: (index) => onTap(index),
    );
  }
}

class TabItem {
  const TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.initialLocation,
  });
  final String icon;
  final String activeIcon;
  final String label;
  final String initialLocation;
}
