import 'package:flutter/material.dart';
import 'dart:async';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../education/screens/education_screen.dart';
import '../../transfer/screens/transfer_point_page.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_fab.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/models/education_model.dart';
import '../../education/screens/article_detail_screen.dart';
import '../../education/screens/video_detail_screen.dart';
import '../../deposit/screens/deposit_option_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  final _notificationRepository = NotificationRepository();
  Timer? _autoScrollTimer;

  final List<String> _carouselImages = [
    'assets/Dashboard 1.png',
    'assets/Dashboard 2.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _carouselIndex) {
        setState(() => _carouselIndex = page);
      }
    });

    // Auto-scroll carousel every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_carouselIndex + 1) % _carouselImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int get _unreadNotificationCount {
    return _notificationRepository
        .getNotifications()
        .where((notif) => !notif.isRead)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/Avatar.png'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Selamat pagi,',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Lucas Scott ðŸ‘‹',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Spacer(),
            NotificationBadge(
              count: _unreadNotificationCount,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _BalanceCard(),
              const SizedBox(height: 24),
              // Quick Action Buttons
              _QuickActionButtons(context: context),
              const SizedBox(height: 24),
              _Carousel(
                controller: _pageController,
                images: _carouselImages,
                index: _carouselIndex,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edukasi Terpopuler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EducationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See more',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _EducationGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFAB(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DepositOptionScreen(),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() => _currentIndex = 0);
          } else if (index == 1) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
              (route) => false,
            );
          } else if (index == 3) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1FA46D), Color(0xFF0F7B56)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single unified card with balance and transfer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFCFE6DD),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D5CC9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  '7.500',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransferPointPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DBF74),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Transfer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final int index;
  const _Carousel({
    required this.controller,
    required this.images,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 190,
            child: Stack(
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  itemBuilder:
                      (context, i) => Container(
                        color: const Color(0xFFF6F7FB),
                        child: Image.asset(
                          images[i],
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                        ),
                      ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) {
                      final active = i == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EducationGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final educationItems = [
      {
        'image': 'assets/Image (1).png',
        'title': 'Mendaur ulang sampah\nsecara mandiri',
        'isVideo': false,
      },
      {
        'image': 'assets/Image (2).png',
        'title': 'Membuat pupuk organik\nuntuk tanaman',
        'isVideo': true,
      },
      {
        'image': 'assets/Frame 22 (1).png',
        'title': 'Bahaya mikroplastik\ndalam tubuh kita',
        'isVideo': false,
      },
      {
        'image': 'assets/Frame 22.png',
        'title': 'Ayo lakukan Zero Waste\nlifestyle',
        'isVideo': false,
      },
    ];

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: 2, // 2 pages (each showing 2 cards)
        itemBuilder: (context, pageIndex) {
          final startIndex = pageIndex * 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Expanded(
                  child: _EducationCard(
                    image: educationItems[startIndex]['image']! as String,
                    title: educationItems[startIndex]['title']! as String,
                    onTap: () {
                      if (educationItems[startIndex]['isVideo'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VideoDetailScreen(
                                  video: VideoModel(
                                    id: '1',
                                    title: (educationItems[startIndex]['title']! as String).replaceAll('\n', ' '),
                                    imageAsset:
                                        educationItems[startIndex]['image']!
                                            as String,
                                    author: 'iTrashy',
                                    timeAgo: '1 bulan lalu',
                                  ),
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ArticleDetailScreen(
                                  article: ArticleModel(
                                    id: '1',
                                    title: (educationItems[startIndex]['title']!
                                            as String)
                                        .replaceAll('\n', ' '),
                                    imageAsset:
                                        educationItems[startIndex]['image']!
                                            as String,
                                    author: 'iTranshy',
                                    timeAgo: '1 months ago',
                                  ),
                                ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EducationCard(
                    image: educationItems[startIndex + 1]['image']! as String,
                    title: educationItems[startIndex + 1]['title']! as String,
                    onTap: () {
                      if (educationItems[startIndex + 1]['isVideo'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VideoDetailScreen(
                                  video: VideoModel(
                                    id: '2',
                                    title: (educationItems[startIndex + 1]['title']! as String).replaceAll('\n', ' '),
                                    imageAsset:
                                        educationItems[startIndex + 1]['image']!
                                            as String,
                                    author: 'iTrashy',
                                    timeAgo: '1 bulan lalu',
                                  ),
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ArticleDetailScreen(
                                  article: ArticleModel(
                                    id: '2',
                                    title: (educationItems[startIndex +
                                                1]['title']!
                                            as String)
                                        .replaceAll('\n', ' '),
                                    imageAsset:
                                        educationItems[startIndex + 1]['image']!
                                            as String,
                                    author: 'iTranshy',
                                    timeAgo: '1 months ago',
                                  ),
                                ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;
  const _EducationCard({
    required this.image,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButtons extends StatelessWidget {
  final BuildContext context;
  const _QuickActionButtons({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.school_outlined,
            label: 'Education',
            backgroundColor: const Color(0xFFEAF2FF),
            iconColor: const Color(0xFF1C62D0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EducationScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.shopping_bag_outlined,
            label: 'Orders',
            backgroundColor: const Color(0xFFFFF1F1),
            iconColor: const Color(0xFFCB2E2E),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


