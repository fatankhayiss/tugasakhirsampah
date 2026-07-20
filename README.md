# Bank Sampah Bersinar — Digital Waste Pick-up & Management Ecosystem (`iTrashy`)

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Flutter: 3.20+](https://img.shields.io/badge/Flutter-3.20%2B-02569B?logo=flutter)
![PHP: 8.1+](https://img.shields.io/badge/PHP-8.1%2B-777BB4?logo=php)
![MySQL: 5.7+](https://img.shields.io/badge/MySQL-5.7%2B-4479A1?logo=mysql)

---

## 1. General Project Overview

**Bank Sampah Bersinar (`iTrashy`)** is a modern, integrated digital waste management ecosystem designed to streamline residential waste pick-up logistics, ensure physical weight accuracy, and provide transparent reward point distribution (`Tukar Poin`) to citizens.

The ecosystem connects three distinct user personas across three synchronized applications:
1. **Citizen Application (`/Mobile`)**: Built with Flutter & Material Design 3. Allows households to request waste pick-ups, utilize AI-based waste scanning, track drivers in real-time, earn eco-points, and redeem points (`Tukar Poin`).
2. **Driver Application (`/Halaman-Driver`)**: Built with Flutter. Empowers operational logistics personnel to accept pick-up tasks, navigate turn-by-turn to citizen residences, and record initial on-site waste weights (`berat_driver_kg`).
3. **Backend & Web Admin (`/bank_sampah`)**: Built with PHP Native & MySQL (`db_banksampah`). Serves as the central data engine, JWT/Bearer authentication provider, and warehouse validation panel where officers perform final quality inspection and weight verification (`berat_aktual_kg`).

---

## 2. Folder Structure

The repository is organized into three clean, self-contained sub-projects alongside centralized Single Source of Truth (SSOT) documentation:

```text
c:\laragon\www\tugasakhirsampah\
├── Mobile\                 # Citizen Application (Flutter / Dart / Material Design 3)
│   ├── lib\
│   │   ├── core\           # Services (AppInitializerService, ApiService, GoogleAuthService)
│   │   ├── features\       # Modular Features (auth, home, deposit, orders, profile)
│   │   └── shared\         # Shared M3 Widgets & Design Tokens
│   └── pubspec.yaml
├── Halaman-Driver\         # Driver Application (Flutter / Dart)
│   ├── lib\
│   │   ├── screens\        # Active task dashboard, navigation, weight verification
│   │   └── services\       # Driver authentication & location tracking
│   └── pubspec.yaml
├── bank_sampah\            # Backend REST API & Web Admin Panel (PHP Native / MySQL)
│   ├── modules\api\        # Modular procedural endpoints (auth, orders, driver, reward)
│   ├── banksampah.sql      # Official database schema and initial seed data
│   └── admin.php           # Warehouse final validation web interface
├── README.md               # General overview, installation, and basic usage guide
├── PROJECT_HANDOVER.md     # Single Source of Truth: Complete architecture, business rules & API
└── CHANGELOG.md            # Consolidated version history & release notes
```

---

## 3. Installation & Prerequisites

To develop, test, and run the complete Bank Sampah Bersinar ecosystem on your local machine, ensure you have the following installed:

### A. System Requirements
- **Operating System**: Windows 10/11 (recommended with Laragon or XAMPP), macOS, or Linux.
- **Flutter SDK**: Version `3.20.0` or higher (`flutter doctor` must report no core issues).
- **PHP**: Version `8.1` or higher with `mysqli`, `curl`, and `mbstring` extensions enabled.
- **MySQL / MariaDB**: Version `5.7+` (or `10.4+` for MariaDB).

### B. Database Setup
1. Launch Laragon or XAMPP and start the **Apache** and **MySQL** services.
2. Open your MySQL client (e.g., phpMyAdmin at `http://localhost/phpmyadmin`).
3. Create a new database named `db_banksampah`:
   ```sql
   CREATE DATABASE db_banksampah CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
4. Import the official database schema and seed data from `bank_sampah/banksampah.sql` or run the automated migration script via terminal:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\bank_sampah
   php run_migrations.php
   ```

---

## 4. Running the Project

### A. Backend & Web Admin (`/bank_sampah`)
Ensure the local web server serves the backend directory directly at:
- **Base URL**: `http://localhost/tugasakhirsampah/bank_sampah/` (or your local LAN IP such as `http://192.168.110.61/tugasakhirsampah/bank_sampah/` when testing on physical mobile devices).
- **Demo Web Admin Login**:
  - URL: `http://localhost/tugasakhirsampah/bank_sampah/admin.php`
  - Username: `admin` | Password: `admin123`

### B. Citizen Mobile Application (`/Mobile`)
1. Open a terminal inside `/Mobile`:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\Mobile
   ```
2. Verify the backend IP address inside `lib/core/constants/api_config.dart`:
   ```dart
   // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator, or your LAN IP for physical hardware
   static const String baseUrl = 'http://192.168.110.61/tugasakhirsampah/bank_sampah/';
   ```
3. Install dependencies and run the app:
   ```powershell
   flutter pub get
   flutter run
   ```

### C. Driver Mobile Application (`/Halaman-Driver`)
1. Open a terminal inside `/Halaman-Driver`:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\Halaman-Driver
   ```
2. Verify the backend IP address inside `lib/constants/api_config.dart`.
3. Install dependencies and run the app:
   ```powershell
   flutter pub get
   flutter run
   ```

---

## 5. Basic Usage & Quick Links

- **For Human Engineers & AI Assistants**: Read **[`PROJECT_HANDOVER.md`](file:///C:/laragon/www/tugasakhirsampah/PROJECT_HANDOVER.md)** before writing code or modifying features. It serves as the absolute **Single Source of Truth (SSOT)** detailing the 3-Stage Weighing Model, 6-Stage Order Status ENUM, JWT Authentication specs, just-in-time mandatory address verification, and complete REST API endpoints.
- **For Version History & Release Notes**: Check **[`CHANGELOG.md`](file:///C:/laragon/www/tugasakhirsampah/CHANGELOG.md)** for detailed chronological logs of all architectural milestones, UI motion improvements, and feature deployments (`v2.1.0`).

---

*Documentation maintained by the Bank Sampah Bersinar Engineering Team.*
