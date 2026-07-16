import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../shared/widgets/exit_app_dialog.dart';
import 'home_screen.dart';
import '../../notification/screens/notifications_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Main shell — bottom nav + tab pages + double-back exit.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final bool autoOpenEditAddress;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.autoOpenEditAddress = false,
  });

  /// Safely switches to the specified tab index from anywhere in the app while maintaining the BottomNavigationBar.
  static void switchTab(
    BuildContext context,
    int index, {
    bool autoOpenEditAddress = false,
    int ordersInitialTabIndex = 0,
  }) {
    final navState = context.findAncestorStateOfType<MainNavigationScreenState>() ?? MainNavigationScreenState.instance;
    if (navState != null) {
      // Pop any routes that are pushed on top of MainNavigationScreen
      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/main');
      navState.setTab(
        index,
        ordersInitialTabIndex: ordersInitialTabIndex,
        autoOpenEditAddress: autoOpenEditAddress,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/main'),
          builder: (_) => MainNavigationScreen(
            initialIndex: index,
            autoOpenEditAddress: autoOpenEditAddress,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  static MainNavigationScreenState? instance;
  late int _currentIndex;
  int _ordersInitialTabIndex = 0;
  bool _autoOpenEditAddress = false;
  final _notificationRepository = NotificationRepository();

  List<Widget> get _screens => [
    const HomeScreen(),
    OrdersScreen(
      key: ValueKey('orders_screen_$_ordersInitialTabIndex'),
      initialTabIndex: _ordersInitialTabIndex,
    ),
    const NotificationsScreen(),
    ProfileScreen(
      key: ValueKey('profile_screen_$_autoOpenEditAddress'),
      autoOpenEditAddress: _autoOpenEditAddress,
    ),
  ];

  @override
  void initState() {
    super.initState();
    instance = this;
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _autoOpenEditAddress = widget.autoOpenEditAddress;
    _notificationRepository.addListener(_onNotificationChange);
  }

  @override
  void dispose() {
    if (instance == this) {
      instance = null;
    }
    _notificationRepository.removeListener(_onNotificationChange);
    super.dispose();
  }

  void _onNotificationChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _autoOpenEditAddress = false;
      if (index == 1) {
        _ordersInitialTabIndex = 0; // Default to Ongoing when clicked from navbar
      }
    });
  }

  void setTab(int index, {int ordersInitialTabIndex = 0, bool autoOpenEditAddress = false}) {
    setState(() {
      _ordersInitialTabIndex = ordersInitialTabIndex;
      _autoOpenEditAddress = autoOpenEditAddress;
      _currentIndex = index.clamp(0, 3);
    });
  }

  Future<void> _handleBackPress() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    await ExitAppDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isEntering = child.key == ValueKey<int>(_currentIndex);
            final fade = CurvedAnimation(
              parent: animation,
              curve: isEntering ? Curves.easeOutCubic : Curves.easeInCubic,
            );
            final slide = Tween<Offset>(
              begin: isEntering ? const Offset(0, 0.04) : Offset.zero,
              end: Offset.zero,
            ).animate(fade);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          unreadCount: _notificationRepository.unreadCount,
        ),
      ),
    );
  }
}
