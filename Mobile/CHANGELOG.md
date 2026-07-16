# CHANGELOG — Citizen Mobile Application (`iTrashy`)

All notable changes to the Bank Sampah Bersinar Citizen Mobile application will be documented in this file.

## [2.1.0] - 2026-07-16

### Summary
Major release completing the **Citizen Mobile UI/UX Refinement**, **Application Initializer Architecture**, **Reward Redemption Module (`Tukar Poin`) Polish**, **Google Authentication Account Picker Enforcement**, and **Comprehensive 0-Issue Analyzer Audit** while strictly preserving Material Design 3 and existing business logic.

---

### Features Added
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
  * 4-Stage Timeline integrated with backend timestamps (`submitted_at`, `verified_at`, `processed_at`, `completed_at`).
  * Conditional Proof of Transfer (`_buildProofSection`) with interactive modal preview when `transfer_proof_url` is returned by the backend.

---

### Features Improved
* **Nomenclature Standardization (`Transfer Poin` -> `Tukar Poin`)**: Completed a full audit across the codebase to ensure consistent user-facing terminology. Updated page titles and warning dialogs in `lib/features/profile/screens/transfer_point_page.dart`.
* **Processing Status Color System**: Replaced residual blue styling for `processing` with the app's primary/soft green theme (`#EAF8EF` background, `AppColors.primary` `#2DAA63` text) for exact visual consistency across the application.
* **Single Navigation Decision Point**: Synchronized background initialization (`initFuture`) with the master `2200ms` visual animation (`animFuture`) inside `lib/features/auth/screens/splash_screen.dart`. Ensures exactly one route transition occurs right when both tasks finish (`AppRoutes.main` or `AppRoutes.login`), eliminating double navigation jumps.

---

### UI & Responsive Improvements
* **Splash Screen Layout Alignment**: Anchored the bottom illustration (`AppImages.loadingScreen`) to `Alignment.bottomCenter` inside a `Transform.translate` bound to `Fit.fitWidth`, ensuring zero clipping or gap across all Android screen sizes (small phones, large phones, tablets, foldables).
* **Brand Tagline & Title**: Updated the brand title text under the circular logo on the Splash Screen to **`I-Trashy`** with modern typography (`Plus Jakarta Sans`).

---

### Authentication Improvements
* **Google Sign-In Account Picker Revocation**: Updated `lib/core/services/google_auth_service.dart` logout flow to call both `GoogleSignIn.signOut()` and `GoogleSignIn.disconnect()` after `FirebaseAuth.instance.signOut()`. This ensures cached tokens are cleared and the Google Account Picker is always presented cleanly on the next login attempt.
* **Session Restoration & Resumption**: Cold launch seamlessly routes based on token availability while app resumption (`didChangeAppLifecycleState`) silently refreshes user profile and points without restarting the splash sequence.

---

### Bug Fixes & Code Quality
* **Removed Duplicate Splash Intro**: Cleaned up deprecated duplicate implementation `splash_intro_screen.dart` to ensure `splash_screen.dart` is the single source of truth for app startup.
* **Zero Analyzer Issues (`flutter analyze`)**:
  * Fixed `use_build_context_synchronously` warnings across async gaps in `lib/features/deposit/screens/scan_screen.dart` by enforcing strict `if (!mounted) return;` checks inside `State`.
  * Fixed generic type parameters for `Future.wait<dynamic>` inside `splash_screen.dart`.
  * Cleaned up optional parameter lints in `register_screen.dart`.
  * **Result**: `0 issues` found across all files.

---

### Breaking Changes
* None. All business logic, routes (`AppRouter`), API endpoints (`api_config.dart`), and backend schemas (`db_banksampah`) remain strictly backwards compatible and preserved.
