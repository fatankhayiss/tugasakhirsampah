# PROJECT_HANDOVER.md — Bank Sampah Bersinar Technical & Architectural Handover
**Project Name:** Sistem Informasi Bank Sampah Bersinar (Mobile Tugas Akhir — Citizen, Driver & Web Admin)  
**Document Purpose:** Definitive Onboarding Guide & Comprehensive Audit Report for Human Developers and AI Assistants  
**Single Source of Truth (SSOT) Version:** 2.0 (Post-UI Polish & Core Business Rule Lockdown)  
**Last Updated:** July 2026  

---

## EXECUTIVE SUMMARY & AUDIT OVERVIEW
This document serves as the **Single Source of Truth (SSOT)** and comprehensive technical handover for the **Bank Sampah Bersinar** ecosystem (`iTrashy`). It consolidates all previous documentation (`MASTER_PROJECT_PLAN.md`, `DEVELOPMENT_HANDOVER.md`, `FEATURE_INVENTORY.md`, `SCREEN_CATALOG.md`, `UI_REQUIREMENTS.md`) and reconciles them against the active production codebase.

The system is composed of three interconnected sub-systems:
1. **Citizen Application (`/Mobile`)**: Built with Flutter & Material Design 3. Serves households for waste pickup requests, AI waste scanning, real-time tracking, and eco-points accumulation.
2. **Driver Application (`/Halaman-Driver`)**: Built with Flutter. Serves operational logistics personnel for task assignment, turn-by-turn navigation, and on-site initial weighing (`berat_driver_kg`).
3. **Backend & Web Admin (`/bank_sampah`)**: Built with PHP Native (Modular Procedural REST API & MySQL `db_banksampah`). Serves as the central data engine, JWT/Bearer auth provider, and warehouse final validation panel (`berat_aktual_kg`).

---

## 1. DOCUMENTATION VS. IMPLEMENTATION RECONCILIATION
During the rigorous inspection of the codebase vs. existing project documentation, several evolutions were discovered. Below is the explicit reconciliation establishing the **New Single Source of Truth**:

### A. Order Status Workflow (6-Stage Backend vs. 7-Stage UI Timeline)
- **What is Different:**
  - `MASTER_PROJECT_PLAN.md` & `FEATURE_INVENTORY.md` document a **6-Stage Status ENUM**: `pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`.
  - `DEVELOPMENT_HANDOVER.md` and the active code in `Mobile/lib/features/orders/screens/order_detail_screen.dart` (`_getStepIndex()`) render a **7-Stage Visual Timeline**:
    1. *Permintaan Dikirim* (`pending`)
    2. *Menunggu Konfirmasi* (UI Sub-state)
    3. *Driver Ditugaskan* (`accepted`)
    4. *Driver Menuju Lokasi* (`on_the_way`)
    5. *Sampah Dijemput* (`picked_up` — Tahap 2 Driver Weighing)
    6. *Validasi Bank Sampah* (`validating` — Tahap 3 Admin Weighing)
    7. *Selesai* (`completed` — Points Dispersed)
- **Why it is Different:** The UI splits `pending` into two user-facing milestones (*Permintaan Dikirim* and *Menunggu Konfirmasi*) to give citizens better psychological visibility during high-volume pickup dispatch queues, while the database strictly maintains 6 atomic state transitions.
- **New Single Source of Truth:** **The 6-Stage Database ENUM backed by the 7-Stage UI Presentation** is the official SSOT. Database migrations and API payloads must strictly use `pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, and `completed`.

### B. Citizen Registration & Mandatory Address Enforcement
- **What is Different:**
  - `UI_REQUIREMENTS.md` & `SCREEN_CATALOG.md` specify a 6-field registration form including `nama_lengkap` (Full Name) and `alamat` (Full Address).
  - The current implementation in `Mobile/lib/features/auth/screens/register_screen.dart` **removed `nama_lengkap` and `alamat` entirely**. Registration now requires only: `username`, `email`, `nomor_hp`, `password`, and `confirm_password`. Address defaults to an empty string (`''`).
  - To prevent invalid pickups, `Mobile/lib/core/utils/address_verification_helper.dart` (`checkAndPrompt`) intercepts every deposit initiation (*Setor Manual*, *Scan AI*, *Checkout*) and enforces address completion via an M3 modal dialog if `alamat` is empty or `'-'`.
- **Why it is Different:** This structural change reduces user onboarding friction (*time-to-first-value*) while guaranteeing 100% address accuracy when the user actually initiates a logistical transaction.
- **New Single Source of Truth:** **Streamlined Identity (`username` primary) + Just-in-Time Mandatory Address Verification** is the official SSOT.

### C. Profile Picture Synchronization & Profile Info Modal
- **What is Different:**
  - Older specs treated the Profile Page as a static list and did not define cross-screen avatar broadcasting or windowed editing.
  - The implementation (`Mobile/lib/features/profile/screens/profile_screen.dart`) features **Broadcast-Driven Profile Synchronization**. Whenever a user updates their profile or avatar, `ProfileRepository().profileUpdateController` broadcasts to instantly refresh `HomeScreen`, `ProfileScreen`, and active dialogs. If unassigned, the system renders a clean Material `person` circular avatar (`never empty`). Furthermore, profile inspection is encapsulated in a windowed modal (`ProfileInfoDialog`).
- **Why it is Different:** To maintain visual continuity across the M3 eco-fintech interface and prevent stale profile data across cached screens.
- **New Single Source of Truth:** **Stream-Driven Broadcast Synchronization + Modal Profile Windows** is the official SSOT.

### D. UI Polish & Motion Design System
- **What is Different:** The current implementation introduces a comprehensive **Material Design 3 Motion Pass** not detailed in `UI_REQUIREMENTS.md`:
  - **Shared Axis Page Transitions**: `AppPageTransitions` (`lib/core/navigation/app_page_transitions.dart`) applies 280ms `easeOutCubic` Shared Axis (`Fade + Slide Up`) and secondary scaling (`1.0 -> 0.98`) across all routes.
  - **Staggered Card Motion**: `StaggeredCardAnimation` (`lib/shared/widgets/staggered_animation.dart`) orchestrates sequential 50ms entry delays on `HomeScreen`.
  - **M3 Modal Motion**: `AppDialogTransitions` (`lib/core/navigation/app_dialog_transitions.dart`) standardizes all 18 dialogs/bottom sheets to `Fade + Scale` (0.90 -> 1.0) and rounded slide sheets (`top: Radius.circular(24)`).
  - **Micro-Interactions & Shimmer**: `ScaleTap` (0.97 scale), `PrimaryButton` elevation dynamics, `AnimatedSwitcher` on balance counters (`PointBadge`), and `ShimmerSkeleton` (`skeleton_loader.dart`).
- **New Single Source of Truth:** The code in `Mobile/lib/core/navigation/` and `Mobile/lib/shared/widgets/` is the official SSOT for all motion and UI standards.

---

## 2. GIT WORKSPACE INVENTORY & FILE STRUCTURE AUDIT

### A. Modified Files (Changes Currently Active in Workspace)
- **Citizen App (`Mobile/`)**:
  - `lib/core/constants/api_config.dart`: Hardcoded base URL IP adjustments.
  - `lib/core/models/profile_model.dart`: Null-safety and default address (`''`) bindings.
  - `lib/core/navigation/app_page_transitions.dart`: Shared Axis M3 motion upgrades.
  - `lib/core/repositories/auth_repository.dart` & `profile_repository.dart`: Broadcast stream controllers and token persistence.
  - `lib/core/services/api_service.dart`: Streamlined HTTP headers and error interceptors.
  - `lib/features/auth/screens/login_screen.dart`, `register_screen.dart`, `splash_screen.dart`, `splash_intro_screen.dart`: UI Polish, responsive `LayoutBuilder` refactor, and streamlined registration fields.
  - `lib/features/deposit/screens/checkout_screen.dart`, `deposit_option_screen.dart`, `manual_deposit_screen.dart`, `scan_screen.dart`: Address verification guards (`checkAndPrompt`) and `AppDialogTransitions` migration.
  - `lib/features/deposit/widgets/deposit_method_modal.dart`: Slide bottom sheet transition upgrade.
  - `lib/features/home/screens/home_screen.dart`: `StaggeredCardAnimation` wrapping across balance, actions, carousel, and education grids.
  - `lib/features/orders/screens/order_detail_screen.dart`: 7-stage timeline validation and M3 cancel dialog.
  - `lib/features/profile/screens/profile_screen.dart`: Complete migration of 11 dialogs/bottom sheets to `AppDialogTransitions` and `ProfileInfoDialog` implementation.
  - `lib/shared/widgets/exit_app_dialog.dart`, `point_badge.dart`, `primary_button.dart`, `scale_tap.dart`: Micro-interaction enhancements (`AnimatedSwitcher`, `AnimatedScale`, ripple effects).
- **Driver App (`Halaman-Driver/`)**:
  - `lib/screens/login_screen.dart` & `services/auth_service.dart`: Driver authentication and token alignment.
- **Backend (`bank_sampah/`)**:
  - `modules/api/auth_api.php` & `profile_api.php`: Support for `username`-primary registration and profile updates.

### B. Added / Untracked Core Files
- `Mobile/lib/core/navigation/app_dialog_transitions.dart`: Centralized M3 Fade+Scale dialog and slide bottom sheet handler.
- `Mobile/lib/core/services/google_auth_service.dart`: Google Sign-In OAuth handler.
- `Mobile/lib/core/utils/address_verification_helper.dart`: Global interceptor for mandatory address checks.
- `Mobile/lib/shared/widgets/skeleton_loader.dart` (`shimmer_loader.dart` & `staggered_animation.dart`): Reusable shimmer placeholder and staggered entrance controllers.
- `bank_sampah/check_pengguna_columns.php` & `bank_sampah/migrations/`: Schema validation helpers.

### C. Unused, Debug & Dead Code (Identified for Clean-up Before Production)
- **Root Directory (`/`)**: `test_api.dart`, `erd_bank_sampah.md` (superseded by SSOT docs).
- **Backend Root (`bank_sampah/`)**:
  - Test & Debug Scripts: `test.php`, `test_api.php`, `test_data.php`, `test_db.php`, `test_edukasi.php`, `test_pengguna.php`, `test_update.php`, `testdb.php`, `testdb2.php`, `testdb3.php`, `testdb4.php`, `testdb5.php`.
  - Schema Inspection Scripts: `cek.php`, `check_db.php`, `check_orders.php`, `check_pengguna.php`, `check_pengguna_columns.php`, `check_tables.php`, `show_tables.php`.
  - *Note:* These files must be removed or moved outside public web root prior to production deployment to prevent exposure of database credentials and schema definitions.

---

## 3. TECHNICAL DEBT & RISK AUDIT (DOCUMENTED ONLY)
Per project guidelines, the following potential issues and architectural debts are documented for human developers and AI assistants to address in future sprints (`Do NOT automatically fix`):

| Category | Location / File | Description & Impact | Recommendation for Next Sprint |
| :--- | :--- | :--- | :--- |
| **Security / SQLi** | `bank_sampah/modules/api/auth_api.php` (Line 343)<br>`detect.php`, `orders_api.php`, `jenis_sampah_api.php` | Raw `mysqli_query` executions using direct string interpolation (e.g., `WHERE username = '$username'`) instead of `mysqli_prepare` / Prepared Statements. High SQL Injection risk. | Refactor all query executions in `modules/api/*.php` to use PHP `mysqli_prepare()` with `$stmt->bind_param()` strictly. |
| **Security / Exposure** | `bank_sampah/*.php` (`test_*.php`, `check_*.php`) | 19+ standalone test and schema-check scripts reside directly in the public web document root (`bank_sampah/`). | Move all debug tools to a private `/scripts/` folder outside the Laragon/Apache web root or delete before production. |
| **Configuration** | `Mobile/lib/core/constants/api_config.dart`<br>`Halaman-Driver/lib/constants/api_config.dart` | `ApiConfig.baseUrl` is hardcoded to `http://192.168.167.68/tugasakhirsampah/bank_sampah/`. Will fail on physical devices on different networks or when deployed to production. | Implement Flutter Environment Variables (`--dart-define=API_URL=...` or `flutter_dotenv`) so builds adapt cleanly between local, staging, and production. |
| **Architecture / Duplication** | `Mobile/lib/` vs.<br>`Halaman-Driver/lib/` | Both Citizen and Driver Flutter apps maintain separate copies of `ApiService`, `WilayahService`, `PrimaryButton`, and `ApiConfig`. | Migrate to a Dart Monorepo with a shared internal package (`package:bank_sampah_core`) for unified HTTP clients, models, and shared M3 widgets. |
| **Performance / Sync** | `Mobile/lib/features/orders/screens/order_detail_screen.dart`<br>`Halaman-Driver/screens/dashboard_screen.dart` | Order status and driver location updates currently rely on HTTP polling or local simulations (`DriverTrackingScreen`). | Integrate WebSocket (Pusher / Socket.io) or Firebase Cloud Messaging (FCM) data payloads for real-time order state pushes. |
| **Lint / Clean Code** | `Mobile/lib/features/auth/screens/register_screen.dart` (Lines 528-530)<br>`checkout_screen.dart` (Lines 244, 248) | Minor Dart static analysis warnings: 3 unused optional parameters in `register_screen.dart` and `BuildContext across async gaps` in `checkout_screen.dart`. | Remove unused parameters and add `if (!context.mounted) return;` safety checks across async gaps. |
| **Business Logic** | `bank_sampah/admin.php` | Web Admin validation panel is currently at ~60% completion. Needs atomic database transactions (`START TRANSACTION` / `COMMIT`) when recording `berat_aktual_kg` and updating `pengguna.saldo`. | Finalize `admin.php` warehouse validation endpoint with strict ACID compliance to lock the 3-stage weighing model. |

---

## 4. DEFINITIVE ONBOARDING GUIDE

### A. Environment Setup & Prerequisites
1. **Operating System:** Windows 10/11 (with Laragon / XAMPP installed) or macOS/Linux.
2. **Flutter SDK:** Version `3.20.0` or higher (tested with Dart `3.3.0+`).
3. **PHP & Database:** PHP `8.1+` with `mysqli` extension enabled; MySQL `5.7+` or MariaDB `10.4+`.
4. **Local Network Configuration:**
   - Ensure Laragon/Apache is serving `c:\laragon\www\tugasakhirsampah\bank_sampah`.
   - Ensure Windows Defender Firewall allows incoming HTTP traffic on port 80 for local network testing on physical mobile devices (`192.168.x.x`).

### B. Database Initialization & Seed
1. Open Laragon/phpMyAdmin or terminal.
2. Create database: `CREATE DATABASE db_banksampah;`.
3. Import the official schema and seeds from `bank_sampah/banksampah.sql` or run the automated migration tool:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\bank_sampah
   php run_migrations.php
   ```

### C. Running the Citizen Mobile Application (`/Mobile`)
1. Navigate to the Citizen app directory:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\Mobile
   ```
2. Check and update the target `baseUrl` inside `lib/core/constants/api_config.dart` to match your local IP (`10.0.2.2` for Android Emulator, `localhost` for iOS Simulator, or your LAN IP for physical phones).
3. Install dependencies and run clean static analysis:
   ```powershell
   flutter pub get
   flutter analyze
   ```
4. Run the application:
   ```powershell
   flutter run
   ```

### D. Running the Driver Application (`/Halaman-Driver`)
1. Navigate to the Driver app directory:
   ```powershell
   cd c:\laragon\www\tugasakhirsampah\Halaman-Driver
   ```
2. Verify `lib/constants/api_config.dart` matches your local server configuration.
3. Launch the driver client:
   ```powershell
   flutter pub get
   flutter run
   ```

### E. AI Assistant Guidelines (How AI Should Interact With This Project)
1. **Always Consult `PROJECT_HANDOVER.md` First:** Before making structural edits or adding features, verify business rules against Section 1 of this document.
2. **Respect Material Design 3 & Motion System:** Do not create ad-hoc transitions or simple `showDialog` / `showModalBottomSheet` calls. Always use `AppDialogTransitions` (`lib/core/navigation/app_dialog_transitions.dart`) and `AppPageTransitions`.
3. **Enforce 3-Stage Weighing & 6-Stage Status ENUM:** When modifying database calls or order screens, strictly adhere to `estimasi_berat_kg` (citizen), `berat_driver_kg` (driver), and `berat_aktual_kg` (admin final authority), paired with the 6 ENUM statuses (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`).
4. **Preserve Address Guards:** Never bypass `AddressVerificationHelper.checkAndPrompt` before waste deposit workflows. Address verification is mandatory just-in-time.
5. **No Blind Automated Fixes:** If new architectural debts or bugs are identified during exploratory analysis, document them clearly under Section 3 rather than performing unprompted global refactors that could destabilize active workflows.

---
*End of Technical Handover Document.*
