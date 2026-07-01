import 'package:flutter/material.dart';

class AppLanguage {
  AppLanguage._();

  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('id'); // 'id' for Indonesian, 'en' for English

  static String get id => currentLanguage.value;

  static void setLanguage(String lang) {
    currentLanguage.value = lang;
  }

  static String translate(String key) {
    final lang = currentLanguage.value;
    final dict = _strings[key];
    if (dict == null) return key;
    return dict[lang] ?? dict['id'] ?? key;
  }

  static final Map<String, Map<String, String>> _strings = {
    // Profile Screen
    'profile': {'id': 'Profil Pengguna', 'en': 'User Profile'},
    'total_waste': {'id': 'Total Sampah', 'en': 'Total Waste'},
    'total_points': {'id': 'Total Poin', 'en': 'Total Points'},
    'menu_notifications': {'id': 'Notifikasi', 'en': 'Notifications'},
    'menu_language': {'id': 'Bahasa / Language', 'en': 'Language / Bahasa'},
    'menu_logout': {'id': 'Keluar Akun', 'en': 'Logout Account'},
    'edit_profile': {'id': 'Edit Profil', 'en': 'Edit Profile'},
    'save_changes': {'id': 'Simpan Perubahan', 'en': 'Save Changes'},
    'cancel': {'id': 'Batal', 'en': 'Cancel'},
    'enter_name': {'id': 'Masukkan nama lengkap', 'en': 'Enter full name'},
    'enter_email': {'id': 'Masukkan email', 'en': 'Enter email address'},
    'select_avatar': {'id': 'Pilih Foto Profil', 'en': 'Select Profile Picture'},
    'select_language': {'id': 'Pilih Bahasa', 'en': 'Select Language'},
    'indonesian': {'id': 'Bahasa Indonesia', 'en': 'Bahasa Indonesia'},
    'english': {'id': 'English (Inggris)', 'en': 'English'},
    
    // Global Navigation Shell / Bottom bar
    'home': {'id': 'Beranda', 'en': 'Home'},
    'orders': {'id': 'Pesanan', 'en': 'Orders'},
    'alerts': {'id': 'Notifikasi', 'en': 'Alerts'},
    
    // Dashboard / Home Screen
    'welcome': {'id': 'Selamat Datang!', 'en': 'Welcome!'},
    'welcome_sub': {'id': 'Mulai daur ulang dan kumpulkan poin hari ini.', 'en': 'Start recycling and earn rewards today.'},
    'eco_balance': {'id': 'Saldo Poin', 'en': 'Point Balance'},
    'cairkan_poin': {'id': 'Tarik Poin', 'en': 'Withdraw Poin'},
    'setor_sampah': {'id': 'Setor Sampah', 'en': 'Deposit Waste'},
    'ongoing_pickup': {'id': 'Jadwal Penjemputan', 'en': 'Pickup Schedules'},
    'education_hub': {'id': 'Hub Edukasi', 'en': 'Learning Hub'},
    'riwayat': {'id': 'Riwayat', 'en': 'History'},

    // Orders Screen
    'ongoing': {'id': 'Berjalan', 'en': 'Ongoing'},
    'history': {'id': 'Riwayat', 'en': 'History'},
    
    // Education Screen
    'education_title': {'id': 'Edukasi Lingkungan', 'en': 'Eco Education'},
    'search_hub': {'id': 'Cari artikel atau video menarik...', 'en': 'Search articles or videos...'},
    'artikel': {'id': 'Artikel', 'en': 'Articles'},
    'video': {'id': 'Video', 'en': 'Videos'},
    
    // Notifications Screen
    'unread': {'id': 'Belum Dibaca', 'en': 'Unread'},
    'mark_all_read': {'id': 'Tandai Semua Dibaca', 'en': 'Mark All as Read'},
  };
}
