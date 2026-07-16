# CHANGELOG — Bank Sampah Bersinar (`iTrashy`) Ecosystem

All notable architectural changes, release notes, and version history across the Bank Sampah Bersinar Citizen Mobile Application (`/Mobile`), Driver Mobile Application (`/Halaman-Driver`), and PHP Backend & Web Admin (`/bank_sampah`) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.1.0] - 2026-07-16

### Summary
Major release completing the **Citizen Mobile UI/UX Polish**, **Application Initializer Architecture Migration**, **Reward Redemption Module (`Tukar Poin`) Lockdown**, **Google Authentication Account Picker Enforcement**, and **Comprehensive Documentation Audit & Consolidation** into a clean Single Source of Truth (`PROJECT_HANDOVER.md`).

---

### Features & Architectural Additions
* **Application Initializer Layer (`AppInitializerService`)**: Converted the static Splash Screen into a background initialization engine (`lib/core/services/app_initializer_service.dart`). Automatically performs 12 sequential/parallel checks on cold launch:
  1. Flutter bindings & orientation verification
  2. Firebase initialization check
  3. Google Authentication readiness check
  4. Previous session restoration (`AuthRepository.instance.isLoggedIn()`)
  5. Current user profile fetch & token validation
  6. Profile photo local synchronization
  7. Local storage configuration (`SharedPreferences`)
  8. Application settings verification
  9. Cache & temporary directory cleanup
  10. Dashboard initial data prefetching (active orders & recent redemptions)
  11. Push notification readiness check
  12. Network connectivity diagnostics
* **Reward Redemption Detail Screen (`RedemptionDetailScreen`)**: Added comprehensive transaction tracking (`lib/features/orders/screens/redemption_detail_screen.dart`):
  * Transaction Number (`TRX-...`), Submission Date, Estimated Processing Time (`1x24 Jam Kerja`), and Current Status table.
  * Dynamic Conversion Rate display (`100 Poin = Rp ...`) calculated directly from API data (`redeem_point` and `estimated_amount`).
  * M3 Information Banner (`#EAF8EF`) explaining manual Admin verification.
  * Color-coded Admin Note Card (`_buildAdminNoteCard`) showing green when completed and red (`#FEE2E2` / `#DC2626`) when rejected.
  * 4-Stage Vertical Status Timeline with actual backend timestamps (`submitted_at`, `verified_at`, `processed_at`, `completed_at`).
  * Proof of Transfer Modal Viewing (`_buildProofSection`) with full-screen pinch-to-zoom when `transfer_proof_url` is returned by the admin.
* **Stream-Driven Profile Broadcast (`profileUpdateController`)**: Added a global broadcast stream in `ProfileRepository` (`lib/core/repositories/profile_repository.dart`) that broadcasts whenever a user updates their profile picture or info, instantly updating `HomeScreen`, `ProfileScreen`, and active dialogs across the app.
* **Just-in-Time Mandatory Address Check (`AddressVerificationHelper`)**: Implemented global interceptors that check `userProfile?.alamat` whenever a citizen taps Setor Manual, Scan AI, or Checkout. If empty or `-`, prompts the user right away via a clean M3 modal dialog.
* **Centralized M3 Dialog & Sheet Transitions (`AppDialogTransitions`)**: Created a single handler (`lib/core/navigation/app_dialog_transitions.dart`) standardizing all 18 dialogs and bottom sheets to Fade+Scale (`0.90 -> 1.0`) and rounded slide sheets (`top: Radius.circular(24)`).

---

### Enhancements & Refactoring
* **Standardized Reward Nomenclature**: Replaced all legacy references of `Transfer Poin` with **`Tukar Poin`** across user-facing strings, navigation headers, and route definitions (`TransferPointPage`).
* **Google Authentication Revocation (`signOut + disconnect()`)**: Updated `GoogleAuthService.logout()` (`lib/core/services/google_auth_service.dart`) to explicitly call `GoogleSignIn.disconnect()` in addition to `signOut()`. This ensures OAuth device tokens are completely revoked, forcing the Android system to show the clean **Google Account Picker** on subsequent logins rather than auto-selecting the previous account.
* **Shared Axis Page Transitions (`AppPageTransitions`)**: Upgraded all route transitions across `lib/core/navigation/app_page_transitions.dart` to use 280ms `easeOutCubic` Shared Axis (`Fade + Slide Up`) and secondary scaling (`1.0 -> 0.98`).
* **Staggered Card Motion (`StaggeredCardAnimation`)**: Wrapped `HomeScreen` cards (greeting, balance banner, quick actions, carousel, and educational grids) with sequential 50ms entrance animations.
* **Micro-Interactions & Shimmer Skeletons**: Added `ScaleTap` (0.97 scale on tap), dynamic elevation on `PrimaryButton`, `AnimatedSwitcher` on `PointBadge` balance counters, and `ShimmerSkeleton` placeholders during network fetches.
* **Streamlined Registration (`RegisterScreen`)**: Removed redundant `nama_lengkap` and `alamat` fields from the registration screen to reduce user friction (`time-to-first-value`). Users register with `username` primary; addresses are collected just-in-time when initiating deposits.
* **Documentation Consolidation**: Merged and organized 23 fragmented project Markdown files into three clean core files at the root: `README.md`, `PROJECT_HANDOVER.md` (SSOT), and `CHANGELOG.md`.

---

### Bug Fixes
* **Async Context Gaps**: Guarded all async/await navigation and dialog triggers across `LoginScreen`, `RegisterScreen`, `SplashScreen`, `ManualDepositScreen`, `ScanScreen`, `CheckoutScreen`, and `ProfileScreen` with strict `if (!mounted) return;` checks.
* **Optional Parameter Cleanup**: Removed unused optional parameters in dialog utilities to satisfy strict Dart static analysis.
* **Dead Code Clean Up**: Removed `SplashIntroScreen` (`splash_intro_screen.dart`), as its functionality was fully absorbed into `AppInitializerService` and `SplashScreen`.

---

## [2.0.0] - 2026-06-15

### Summary
Initial production-ready baseline release establishing the **3-Stage Weighing Model**, **6-Stage Order Status ENUM**, and the core separation between Citizen Mobile (`/Mobile`), Driver Mobile (`/Halaman-Driver`), and PHP Backend & Web Admin (`/bank_sampah`).

---

### Features & Core Architecture
* **3-Stage Weighing Model**: Implemented `estimasi_berat_kg` (citizen stage 1), `berat_driver_kg` (driver stage 2), and `berat_aktual_kg` (warehouse admin stage 3 final authority).
* **6-Stage Order Status ENUM**: Established database migrations and REST payloads enforcing `pending` -> `accepted` -> `on_the_way` -> `picked_up` -> `validating` -> `completed`.
* **7-Stage Visual UI Timeline (`OrderDetailScreen`)**: Created user-friendly 7-step timeline mapping citizen psychological expectations (*Permintaan Dikirim* -> *Menunggu Konfirmasi* -> *Driver Ditugaskan* -> *Driver Menuju Lokasi* -> *Sampah Dijemput* -> *Validasi Bank Sampah* -> *Selesai*).
* **Driver Active Task Workflow (`/Halaman-Driver`)**: Enabled driver task acceptance, en-route status toggles, door-step weight verification (`PickupVerificationScreen`), and 3-item pickup checklist (`PickupCompletionScreen`).
* **PHP Native Procedural REST API (`/bank_sampah/modules/api/`)**: Implemented `auth_api.php`, `orders_api.php`, `driver_api.php`, `profile_api.php`, and `reward_api.php` with JWT/Bearer token authentication.
* **Web Admin Warehouse Panel (`admin.php`)**: Built PHP interface for warehouse sorting validation and final point calculation (`berat_aktual_kg`).
