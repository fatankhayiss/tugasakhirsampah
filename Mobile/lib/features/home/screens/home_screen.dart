import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import 'dart:async';
import 'main_navigation_screen.dart';
import '../../education/screens/education_screen.dart';
import '../../profile/screens/transfer_point_page.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../../shared/widgets/point_badge.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/education_repository.dart';
import '../../../core/models/education_model.dart';
import '../../education/screens/article_detail_screen.dart';
import '../../education/screens/video_detail_screen.dart';
import '../../../core/constants/app_images.dart';
import '../../../shared/widgets/app_asset_image.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/widgets/staggered_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  final _notificationRepository = NotificationRepository();
  Timer? _autoScrollTimer;

  // ===============================
  // IMAGE ASSET CONFIG
  // Gunakan file assets/images/banner_recycle.png dsb
  // ===============================
      final List<String> _carouselImages = [
      AppImages.bannerHome1,
      AppImages.bannerHome2,
    ];

  String _userName = 'Guest';
  String? _avatarUrl;
  String? _userAddress;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    ApiService.instance.profileUpdateNotifier.addListener(_loadUserData);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _carouselIndex) {
        setState(() => _carouselIndex = page);
      }
    });

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_carouselIndex + 1) % _carouselImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.instance.getUserData();
    if (mounted) {
      setState(() {
        if (userData == null) {
          _userName = "Guest";
          _userAddress = null;
          _avatarUrl = null;
        } else {
          final uname = userData['username']?.toString().trim() ?? '';
          _userName = uname.isNotEmpty ? uname : 'User';
          final foto = userData['foto_profil']?.toString() ?? '';
          _avatarUrl = foto.isNotEmpty
              ? (foto.startsWith('http') ? foto : '${ApiConfig.baseUrl}$foto')
              : null;
          final alamat = userData['alamat']?.toString() ?? '';
          _userAddress = alamat.isNotEmpty ? alamat : 'Alamat belum diatur';
        }
      });
    }
  }

  @override
  void dispose() {
    ApiService.instance.profileUpdateNotifier.removeListener(_loadUserData);
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat pagi,';
    } else if (hour < 15) {
      return 'Selamat siang,';
    } else if (hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern clean background
      extendBody: true, // For floating bottom nav bar
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Colors.black.withValues(alpha: 0.05),
                height: 0.5,
              ),
            ),
            automaticallyImplyLeading: false,
            toolbarHeight: 76,
            titleSpacing: 20,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    MainNavigationScreen.switchTab(context, 3);
                  },
                  child: Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? Image.network(
                                _avatarUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: Icon(Icons.person, color: Colors.grey[600], size: 28),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Icon(Icons.person, color: Colors.grey[600], size: 28),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A92A6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_userName 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_userAddress != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 13, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _userAddress!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NotificationBadge(
                  count: _unreadNotificationCount,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.alerts);
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  StaggeredCardAnimation(
                    index: 0,
                    child: _BalanceCard(),
                  ),
                  const SizedBox(height: 24),
                  StaggeredCardAnimation(
                    index: 1,
                    child: _QuickActionButtons(context: context),
                  ),
                  const SizedBox(height: 24),
                  StaggeredCardAnimation(
                    index: 2,
                    child: _Carousel(
                      controller: _pageController,
                      images: _carouselImages,
                      index: _carouselIndex,
                    ),
                  ),
                  const SizedBox(height: 32),
                  StaggeredCardAnimation(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edukasi Terpopuler',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    page: const EducationScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    'Jelajahi Edukasi',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _EducationGrid(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), // Bottom padding for floating nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _transferHover = false;
  bool _transferPressed = false;
  String _balance = '0';

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final userData = await ApiService.instance.getUserData();
    if (userData != null && mounted) {
      setState(() {
        // Asumsi saldo dari API berupa angka utuh / desimal
        final saldoRaw = userData['saldo'] ?? 0;
        final int saldoInt = (saldoRaw is num) ? saldoRaw.toInt() : int.tryParse(saldoRaw.toString()) ?? 0;
        // Format ke ribuan sederhana
        _balance = saldoInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.20),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blur circle — top right
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Decorative blur circle — bottom left
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Decorative blur circle — center right
          Positioned(
            right: 50,
            bottom: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saldo Poin',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: PointBadge.balanceAmount(
                      amount: _balance,
                      fontSize: 36,
                      logoSize: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Glassmorphism Transfer Button
                  MouseRegion(
                    onEnter: (_) => setState(() => _transferHover = true),
                    onExit: (_) => setState(() => _transferHover = false),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _transferPressed = true),
                      onTapUp: (_) {
                        setState(() => _transferPressed = false);
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: const TransferPointPage(),
                          ),
                        );
                      },
                      onTapCancel: () =>
                          setState(() => _transferPressed = false),
                      child: AnimatedScale(
                        scale: _transferPressed ? 0.93 : (_transferHover ? 1.02 : 1.0),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: _transferHover ? 0.22 : 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: _transferHover ? 0.40 : 0.25),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: (MediaQuery.of(context).size.width * 0.48).clamp(150.0, 220.0),
              child: Stack(
                children: [
                  // — Banner image
                  PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    itemBuilder: (context, i) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          AppAssetImage(
                            assetPath: images[i],
                            fit: BoxFit.cover,
                          ),

                          // Subtle eco-green gradient from bottom
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.5, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  AppColors.secondary.withValues(alpha: 0.18),
                                ],
                              ),
                            ),
                          ),

                          // Decorative blur circle — bottom-right
                          Positioned(
                            right: -30,
                            bottom: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.10),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Decorative blur circle — top-left
                          Positioned(
                            left: -20,
                            top: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.12),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Glass highlight — top edge reflection
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // — Modern capsule indicators
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) {
                        final active = i == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 28 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EducationGrid extends StatelessWidget {
  final _repository = EducationRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _repository.getLatestEducation(limit: 4),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: (MediaQuery.of(context).size.height * 0.36).clamp(280.0, 340.0),
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return SizedBox(
            height: (MediaQuery.of(context).size.height * 0.36).clamp(280.0, 340.0),
            child: const Center(child: Text('Belum ada edukasi')),
          );
        }

        return SizedBox(
          height: (MediaQuery.of(context).size.height * 0.36).clamp(280.0, 340.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isVideo = item is VideoModel;
              
              String image;
              bool isNetworkImage = false;
              if (isVideo) {
                isNetworkImage = (item).imageUrl != null;
                image = isNetworkImage ? item.imageUrl! : item.imageAsset;
              } else {
                isNetworkImage = (item as ArticleModel).imageUrl != null;
                image = isNetworkImage ? item.imageUrl! : item.imageAsset;
              }

              final title = isVideo ? (item).title : (item as ArticleModel).title;
              final category = isVideo ? 'VIDEO' : 'ARTIKEL';
              final desc = isVideo ? '' : (item as ArticleModel).description;
              final heroTag = isVideo ? 'video_image_$index' : 'article_image_$index';

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == items.length - 1 ? 0 : 8,
                ),
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width * 0.65).clamp(220.0, 320.0),
                  child: _EducationCard(
                    image: image,
                    isNetworkImage: isNetworkImage,
                    title: title,
                    category: category,
                    desc: desc,
                    heroTag: heroTag,
                    onTap: () {
                      if (isVideo) {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: VideoDetailScreen(video: item),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: ArticleDetailScreen(article: item as ArticleModel),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EducationCard extends StatefulWidget {
  final String image;
  final bool isNetworkImage;
  final String title;
  final String category;
  final String desc;
  final String heroTag;
  final VoidCallback onTap;

  const _EducationCard({
    required this.image,
    this.isNetworkImage = false,
    required this.title,
    required this.category,
    required this.desc,
    required this.heroTag,
    required this.onTap,
  });

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  bool _isHover = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHover ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.withValues(alpha: _isHover ? 0.15 : 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHover ? 0.08 : 0.04),
                  blurRadius: _isHover ? 24 : 12,
                  offset: Offset(0, _isHover ? 8 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.15).clamp(100.0, 150.0),
                    width: double.infinity,
                    child: Hero(
                      tag: widget.heroTag,
                      child: widget.isNetworkImage
                          ? Image.network(widget.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => AppAssetImage(assetPath: AppImages.education1, fit: BoxFit.cover))
                          : AppAssetImage(assetPath: widget.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A92A6),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Text(
                            'Baca Selengkapnya',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            icon: Icons.school_rounded,
            label: 'Edukasi',
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(
                  page: const EducationScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.history_rounded,
            label: 'Riwayat',
            onTap: () {
              final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
              if (navState != null) {
                navState.setTab(1, ordersInitialTabIndex: 1);
              }
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
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
          constraints: BoxConstraints(minHeight: (MediaQuery.of(context).size.height * 0.13).clamp(100.0, 140.0)),
          padding: EdgeInsets.symmetric(
            vertical: (MediaQuery.of(context).size.height * 0.02).clamp(12.0, 20.0),
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0F2F5)),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF5FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}











