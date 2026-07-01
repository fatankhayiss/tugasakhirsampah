/// Single source of truth for all image asset paths.
///
/// Path must match exactly (case-sensitive on Android):
/// - Folder: `assets/images/<category>/`
/// - Register folder in [pubspec.yaml] under `flutter: assets:`
abstract final class AppImages {
  AppImages._();

  // ---------------------------------------------------------------------------
  // Structured paths (preferred — add new images here)
  // ---------------------------------------------------------------------------

  static const String _auth = 'assets/images/auth';
  static const String _home = 'assets/images/home';
  static const String _intro = 'assets/images/intro';

  // ===============================
  // CHANGE INTRO LOGO HERE
  // assets/images/intro/logo.png
  // ===============================
  static const introLogo = '$_intro/logo.png';

  // ===============================
  // CHANGE INTRO ILLUSTRATION HERE
  // assets/images/intro/illustration.png
  // ===============================
  static const introIllustration = '$_intro/illustration.png';

  static const _education = 'assets/images/education';

  // ===============================
  // CHANGE EDUCATION IMAGE HERE
  // assets/images/education/
  // ===============================
  static const education1 = '$_education/education_1.png';
  static const education2 = '$_education/education_2.png';
  static const education3 = '$_education/education_3.png';
  static const education4 = '$_education/education_4.png';

  // =====================================================
  // POINT LOGO
  // FILE:
  // assets/icons/point_logo.png
  //
  // Ganti logo poin di sini
  // =====================================================

  /// Poin currency logo PNG — dipakai di seluruh aplikasi.
  static const pointLogo = 'assets/icons/point_logo.png';

  /// Order logo PNG — dipakai di riwayat/order screen.
  static const orderLogo = 'assets/icons/order_logo.png';

  /// Login / register banner
  static const loginBanner = '$_auth/login_banner.png';

  static const bannerHome1 = '$_home/banner_home_1.png';
  static const bannerHome2 = '$_home/banner_home_2.png';

  static const edukasi1 = '$_home/edukasi_1.png';
  static const edukasi2 = '$_home/edukasi_2.png';
  static const edukasi3 = '$_home/edukasi_3.png';
  static const edukasi4 = '$_home/edukasi_4.png';

  // ---------------------------------------------------------------------------
  // Legacy root assets (explicit in pubspec — filenames may contain spaces)
  // ---------------------------------------------------------------------------

  static const avatar = 'assets/Avatar.png';
  static const coverProfile = 'assets/cover3 1.png';
  static const image1 = 'assets/Image (1).png';
  static const image2 = 'assets/Image (2).png';
  static const image5 = 'assets/Image (5).png';
  static const image3Small = 'assets/image 3.png';
  /// @deprecated Gunakan [pointLogo].
  static const poinLogo = pointLogo;
  static const botolPlastik = 'assets/botol plastik.jpg';
  static const loadingScreen = 'assets/Loading Screen.png';
  static const logoItrashy1 = 'assets/logo Itrashy 1.png';
  static const logoItrashy2 = 'assets/logo Itrashy 2.png';
  static const kumpulkanSampah = 'assets/kumpulkan sampah.png';
  static const tiktok = 'assets/tiktok.png';
  static const frame = 'assets/Frame.png';

  /// Every path used by the app — validated in [test/app_images_test.dart].
  static const List<String> bundled = [
    introLogo,
    introIllustration,
    education1,
    education2,
    education3,
    education4,
    loginBanner,
    bannerHome1,
    bannerHome2,
    edukasi1,
    edukasi2,
    edukasi3,
    edukasi4,
    pointLogo,
    orderLogo,
    avatar,
    coverProfile,
    image1,
    image2,
    image5,
    image3Small,
    botolPlastik,
    loadingScreen,
    logoItrashy1,
    logoItrashy2,
    kumpulkanSampah,
    tiktok,
    frame,
  ];
}
