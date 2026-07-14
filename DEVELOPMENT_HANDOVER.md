# DEVELOPMENT HANDOVER DOCUMENTATION
**Project Name:** Bank Sampah (Mobile Tugas Akhir — Citizen & Driver Apps)  
**Document Purpose:** Comprehensive Technical & Architectural Handover Before GitHub Repository Push  
**Target Audience:** Senior Developers, Mobile Engineers, Backend Engineers, and DevOps Team  
**Last Updated:** July 2026  

---

## 1. PROJECT STATUS

* **Current Development Progress:** **85% Completed**
* **Overall Application Status:** **Stable, Modularized, & Ready for Integration Testing**
* **Architecture Style:** Feature-First Modular Architecture (`lib/features/<module_name>/`) with shared core components (`lib/core/` and `lib/shared/`).

### Module Status Breakdown
| Module / Layer | Status | Completion % | Description |
| :--- | :--- | :---: | :--- |
| **Authentication Module** (`auth/`) | **Completed** | 100% | Login, Register, Splash Intro, Social Login, and Token Persistence. |
| **Home Dashboard Module** (`home/`) | **Completed** | 100% | Dynamic Header, Balance/Points Display, Action Grid, and Educational Tips. |
| **Deposit & Checkout Module** (`deposit/`) | **Completed** | 100% | Manual Deposit, Category Grid, Weight Slider, Checkout Setoran, Scan Screen, and Success Confirmation. |
| **Orders & Tracking Module** (`orders/`) | **Completed** | 100% | Order History, 7-Stage Status Timeline (`OrderDetailScreen`), and Driver Tracking Screen. |
| **Driver Active Task Module** (`Halaman-Driver/`) | **Completed** | 100% | Active Task Dashboard, Pickup Detail, Weight Verification (`PickupVerificationScreen`), and Complete Pickup (`PickupCompletionScreen`). |
| **Backend REST API & Database** (`bank_sampah/`) | **Completed** | 95% | CRUD Orders, Driver Task Filtering, Order Status ENUM Migrations (`orders_api.php`, `driver_api.php`). |
| **Web Admin Validation Panel** (`bank_sampah/admin.php`) | **In Progress** | 60% | Final warehouse inspection, actual weight verification, and final points calculation. |
| **Real-Time GPS Geolocation** | **In Progress** | 40% | Currently uses simulated/dummy coordinates on `DriverTrackingScreen`; requires WebSocket/Pusher integration. |
| **Push Notification Module** (`notification/`) | **Pending** | 20% | UI exists; requires Firebase Cloud Messaging (FCM) backend trigger integration. |

---

## 2. COMPLETED FEATURES

* `✓ Authentication (Login, Register, Social Login Button, Password Reset UI)`
* `✓ Home Dashboard (Action Grid, Real-Time Balance & Points Card, Eco-Education Tips)`
* `✓ Manual Deposit (Multi-Category Waste Selection Grid, Interactive Weight Slider, Dynamic Subtotal Summary)`
* `✓ Pickup Request & Checkout (Address Selection, Time Slot Picker, Driver Notes, Order Submission)`
* `✓ Deposit Success Page (Immediate Order Confirmation, Direct Navigation to Live Status Tracking)`
* `✓ Order Detail & 7-Stage Status Timeline (Permintaan Dikirim -> Menunggu Konfirmasi -> Driver Ditugaskan -> Driver Menuju Lokasi -> Sampah Dijemput -> Validasi Bank Sampah -> Selesai)`
* `✓ Driver Active Tasks & Task Detail (Accept/Confirm Order, Turn-by-Turn Navigation State)`
* `✓ Driver Weight Verification (Actual Weight Input, TextEditingController Binding, Picked Up Status Confirmation)`
* `✓ Driver Pickup Completion & Verification Checklist (Order Summary Display, 3-Item Safety Checklist, Disabled Submit Protection, Validating Status Update, Active Task Auto-Removal)`
* `✓ Backend REST API & Database Migrations (Orders CRUD, Active Task Query Filtering, ENUM Schema Validation)`

---

## 3. UPDATED SCREENS

### A. Citizen / Warga Application (`Mobile/`)

#### 1. `Splash Screen` & `Splash Intro Screen` (`lib/features/auth/screens/`)
* **Purpose:** Initial onboarding and application boot screen.
* **What Changed:** Replaced legacy onboarding with Google Stitch Batch 1 modern minimalist aesthetic. Refactored files from `lib/features/onboarding/` directly into `lib/features/auth/screens/` to maintain modular cohesion.
* **Business Rules:** Checks user authentication token on boot (`ApiService().getToken()`). If valid, redirects directly to `MainNavigationScreen` (`/home`); otherwise shows `LoginScreen`.
* **Current Status:** **Completed & Stable**.

#### 2. `Login Screen` & `Register Screen` (`lib/features/auth/screens/`)
* **Purpose:** Citizen authentication and registration.
* **What Changed:** Updated UI layout with clean rounded cards (20px radius), Plus Jakarta Sans typography, and `SocialLoginButton` integration (`lib/features/auth/widgets/social_login_button.dart`).
* **Business Rules:** All credentials verified against `pengguna` table via `auth_api.php`. Token stored locally via `SharedPreferences`.
* **Current Status:** **Completed & Stable**.

#### 3. `Home Dashboard Screen` (`lib/features/home/screens/home_screen.dart`)
* **Purpose:** Main hub for citizen interactions, balance viewing, and quick navigation.
* **What Changed:** Replaced `home_screen_old.dart` with Google Stitch Batch 1 UI (`WRG-003`). Added dynamic greeting header, real-time balance card, 4-column quick action grid (*Jemput Sampah*, *Scan QR*, *Edukasi*, *Riwayat*), and horizontal education banners.
* **Business Rules:** Displays user balance (`saldo`) and points accurately. Quick actions route directly to their modular feature routes.
* **Current Status:** **Completed & Stable**.

#### 4. `Manual Deposit Screen` (`lib/features/deposit/screens/manual_deposit_screen.dart`)
* **Purpose:** Citizen waste category selection and estimated weight input before checkout.
* **What Changed:** Updated to Material 3 styling. Implemented a 2-column selectable waste category grid (*Plastik*, *Kertas*, *Logam*, *Kaca*, *Elektronik*, *Organik*), interactive weight slider/input, and sticky bottom summary displaying estimated subtotal points.
* **Business Rules:** Citizen must select at least one waste category and set weight $> 0$ kg to enable the primary checkout button.
* **Current Status:** **Completed & Stable**.

#### 5. `Checkout Setoran Screen` (`lib/features/deposit/screens/checkout_screen.dart`)
* **Purpose:** Final review of pickup address, time slots, and notes before submitting order.
* **What Changed:** Replaced legacy UI with full Google Stitch design while strictly preserving existing theme tokens (`#FFFFFF` background, `#006D36` primary text/headers, blue gradient `PrimaryButton`, soft shadow cards).
* **Business Rules:** Submits order payload (`user_id`, `alamat_jemput`, `latitude`, `longitude`, `waktu_jemput_dari`, `waktu_jemput_sampai`, `estimasi_berat`, `estimasi_poin`, `catatan`, `items`) to `POST modules/api/orders_api.php`. Initial status set to `pending`.
* **Current Status:** **Completed & Stable**.

#### 6. `Detail Pesanan Screen` (`lib/features/orders/screens/order_detail_screen.dart`)
* **Purpose:** Citizen real-time order tracking and detail inspection.
* **What Changed:**
  * Fixed status badge in top-right corner to be completely responsive (removed fixed width, applied `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`).
  * Expanded timeline index calculation (`_getStepIndex()`) to support the complete **7-Stage Workflow**:
    1. `Permintaan Dikirim` (`pending`)
    2. `Menunggu Konfirmasi`
    3. `Driver Ditugaskan` (`accepted`)
    4. `Driver Menuju Lokasi` (`on_the_way`)
    5. `Sampah Dijemput` (`picked_up`)
    6. `Validasi Bank Sampah` (`validating`)
    7. `Selesai` (`completed`)
* **Business Rules:** Citizen can cancel order only while status is `pending`. When status reaches `on_the_way` or `picked_up`, citizen can view driver contact and track live location.
* **Current Status:** **Completed & Stable**.

---

### B. Driver Application (`Halaman-Driver/`)

#### 7. `Driver Pickup Detail Screen` (`lib/screens/pickup_detail_screen.dart`)
* **Purpose:** Driver view of assigned task details and turn-by-turn navigation initiator.
* **What Changed:** Modified `_buildAction()` button logic to adaptively transform based on current order status:
  * If `accepted`: Shows `"Konfirmasi Penjemputan"` -> updates status to `on_the_way`.
  * If `on_the_way`: Shows `"Lakukan Verifikasi"` -> opens `PickupVerificationScreen` (`/pickup-verify`).
  * If `picked_up`: Shows `"Selesaikan di Bank Sampah"` -> opens `PickupCompletionScreen` (`/complete-pickup`).
* **Business Rules:** Driver must accept or confirm task progression strictly sequentially.
* **Current Status:** **Completed & Stable**.

#### 8. `Driver Weight Verification Screen` (`lib/screens/pickup_verification_screen.dart`)
* **Purpose:** Driver physical weight measurement and verification at citizen location.
* **What Changed:**
  * Converted from `StatelessWidget` to `StatefulWidget` (`_PickupVerificationScreenState`).
  * Bound `TextEditingController (_weightController)` to the actual weight input field (`Input Berat Aktual`), allowing pre-fill via `Sesuai Estimasi` or `Muatan Penuh` buttons.
  * Replaced bottom primary button text with **`"Konfirmasi Sampah Diangkut"`** (`_mint` green button).
  * When pressed: Saves actual weight, updates status to `picked_up` via `ApiService().updateOrderStatus(task['id_order'], 'picked_up', beratAktual: finalWeight)`, and executes `Navigator.pushReplacementNamed('/complete-pickup', arguments: task)`.
* **Business Rules:** **Do NOT finish the order yet.** Order transitions from `on_the_way` to `picked_up`.
* **Current Status:** **Completed & Stable**.

---

## 4. NEW SCREENS

| Screen Name | File Path | Application | Reason Added |
| :--- | :--- | :--- | :--- |
| **`DepositSubmittedScreen`** | `Mobile/lib/features/deposit/screens/deposit_submitted_screen.dart` | Citizen (`Mobile`) | **Success Page After Checkout:** Provides immediate confirmation after order submission. Updated primary action button from `"Lihat Detail Pesanan"` to `"Lacak Status Pesanan"` (`Icon(Icons.local_shipping)`), routing directly via `pushReplacement` to `OrderDetailScreen`. |
| **`DriverTrackingScreen`** | `Mobile/lib/features/orders/screens/driver_tracking_screen.dart` | Citizen (`Mobile`) | **Real-Time Driver Location:** Dedicated tracking interface displaying driver vehicle info, license plate, phone call action, and live map view when order status is `on_the_way` or `picked_up`. |
| **`PickupCompletionScreen`** | `Halaman-Driver/lib/screens/pickup_completion_screen.dart` | Driver (`Halaman-Driver`) | **Warehouse Delivery & Safety Verification (`/complete-pickup`):** Implements the new final driver workflow step at the Bank Sampah warehouse before submitting to Web Admin. |

### Detailed Architecture of `PickupCompletionScreen` (`/complete-pickup`):
* **Top App Bar:** Titled `'Selesaikan Penjemputan'` with back navigation arrow.
* **Customer Summary Card:** Displays `#ID Order`, Citizen Name (`nama_warga`), and Pickup Address (`alamat_jemput`).
* **Waste Summary (`RINGKASAN SAMPAH TERKUMPUL`):** Shows exact actual weight (`berat_aktual` or `estimasi_berat`) and categorized badges (`jenis_sampah`).
* **Warning Information Card (`_mint` shield container):**
  > *"Dengan mengonfirmasi proses ini, data penjemputan akan dikirim ke Admin Web untuk proses validasi akhir. Driver tidak dapat mengubah data pesanan setelah proses ini selesai."*
* **Checklist Section (`CHECKLIST PENYELESAIAN`):**
  * `[ ] Sampah telah sampai di Bank Sampah`
  * `[ ] Semua sampah telah diturunkan`
  * `[ ] Data penjemputan sudah benar`
* **Submit Action (`"Kirim ke Admin"`):**
  * Bottom button remains **disabled** until all 3 checkboxes are checked (`[true, true, true]`).
  * When clicked, calls `ApiService().updateOrderStatus(task['id_order'], 'validating')`.
  * Shows a confirmation popup dialogue informing the driver that data has been transmitted to Web Admin, accompanied by a **`"Kembali ke Dashboard"`** button that clears the navigation stack (`pushNamedAndRemoveUntil('/dashboard')`).

---

## 5. MODIFIED ROUTES

### A. Citizen Modular Routing (`Mobile/lib/core/routes/app_router.dart`)
```
[Manual Deposit Screen]  (/deposit)
          ↓
[Checkout Setoran Screen]  (/checkout)
          ↓ (pushReplacement)
[Deposit Submitted Screen]  (/deposit-success)
          ↓ (pushReplacement on "Lacak Status Pesanan")
[Order Detail Screen]  (/orders/detail)
          ↓ (on "Lacak Driver")
[Driver Tracking Screen]  (/orders/tracking)
```

### B. Driver Modular Routing (`Halaman-Driver/lib/main.dart`)
```
[Dashboard Screen]  (/dashboard)
          ↓ (on "Mulai Navigasi" or Task Click)
[Pickup Detail Screen]  (/pickup-detail)
          ↓ (on "Lakukan Verifikasi" when status == 'on_the_way')
[Weight Verification Screen]  (/pickup-verify)
          ↓ (pushReplacement on "Konfirmasi Sampah Diangkut" when status == 'picked_up')
[Complete Pickup Screen]  (/complete-pickup)
          ↓ (pushNamedAndRemoveUntil on "Kembali ke Dashboard" after submitting to Admin)
[Dashboard Screen]  (/dashboard) — (Task is removed from active list)
```

---

## 6. BUSINESS FLOW

```
+-------------------+       +--------------------+       +---------------------+
|  Citizen (Warga)  | ----> |  Orders REST API   | ----> | Web Admin / Driver  |
+-------------------+       +--------------------+       +---------------------+
  1. Create Order             2. Status: PENDING           3. Confirm / Assign
     (Checkout)                                               (Status: ACCEPTED)
                                                                      |
                                                                      v
+-------------------+       +--------------------+       +---------------------+
| Web Admin / Bank  | <---- | Complete Pickup    | <---- | Driver Verification |
+-------------------+       +--------------------+       +---------------------+
  6. Final Inspection         5. Checklist & Submit        4. Input Actual Weight
     (Status: VALIDATING)        (Status: VALIDATING)         (Status: PICKED_UP)
          |
          v
+-------------------+
| Completed Reward  |
+-------------------+
  7. Points Dispersed
     (Status: COMPLETED)
```

### Step-by-Step State Transitions:
1. **`pending`**: Citizen creates pickup request via `CheckoutScreen`. Order stored in database; citizen receives confirmation notification.
2. **`accepted`**: Driver accepts task via `Halaman-Driver` (or assigned by Admin). Citizen receives notification: *"Driver sedang menuju lokasi Anda"*.
3. **`on_the_way`**: Driver presses `"Konfirmasi Penjemputan"` and starts driving to citizen address.
4. **`picked_up`**: Driver arrives, weighs waste, inputs actual weight (`berat_aktual`), and presses `"Konfirmasi Sampah Diangkut"`. Citizen status timeline progresses to Stage 5 (`Sampah Dijemput`).
5. **`validating`**: Driver transports waste to Bank Sampah warehouse, checks off all 3 completion checklist items on `/complete-pickup`, and presses `"Kirim ke Admin"`.
   * **Crucial Rule:** Once status changes to `validating`, the backend query `get_active_task` in `driver_api.php` (`status IN ('accepted', 'on_the_way', 'picked_up')`) automatically filters out this order. It immediately disappears from the Driver's ongoing active tasks.
6. **`completed`**: Web Admin inspects physical waste at the warehouse, confirms exact weights, and marks status as `completed`. Points (`estimasi_poin` or actual calculated reward) are credited directly to Citizen's `saldo`.

---

## 7. IMPORTANT BUSINESS RULES

1. **Estimated Weight vs. Reward Points:** Estimated weight (`estimasi_berat`) selected by Citizen during checkout is strictly for planning and vehicle capacity assignment. It **never** locks in or affects final reward points.
2. **Actual Weight Recording:** Actual weight (`berat_aktual_kg`) must be physically measured and entered by the Driver during `PickupVerificationScreen` (`picked_up`).
3. **Reward Point Dispersion:** Reward points are **only** calculated, finalized, and added to Citizen's balance (`pengguna.saldo`) after Web Admin validation (`completed`). Citizen cannot see final dispersed points before status reaches `completed`.
4. **Driver Data Immutability:** Driver **cannot** edit, re-verify, or modify order weight/data once `"Kirim ke Admin"` is submitted (`validating`).
5. **Active Task Auto-Removal:** Any order with status `validating`, `completed`, or `cancelled` **must not** appear on the Driver's ongoing tasks list (`DashboardScreen`).
6. **Design System Adherence:** All screens across Citizen (`Mobile`) and Driver (`Halaman-Driver`) applications **must strictly follow** the established Theme tokens:
   * **Background:** White (`#FFFFFF`) or Light Gray (`#F9FAFB`).
   * **Primary Text:** Dark Green (`#006D36` or `#1E293B`).
   * **Secondary Text:** Muted Gray (`#6D7B6D`).
   * **Primary Button:** Blue Gradient (Citizen) or Green Mint (`#4ADE80` with `#0B4F2A` text in Driver).
   * **Card Style:** White surface (`#FFFFFF`), rounded corners (16px–20px radius), soft subtle box shadow.

---

## 8. FILES MODIFIED

| File Path | Status | Reason |
| :--- | :---: | :--- |
| `Mobile/lib/features/auth/screens/splash_screen.dart` | **NEW** | Re-organized from `splash/` into modular `auth/` directory; integrated Stitch UI. |
| `Mobile/lib/features/auth/screens/splash_intro_screen.dart` | **NEW** | Re-organized onboarding screen into `auth/`; modern minimalist layout. |
| `Mobile/lib/features/auth/screens/login_screen.dart` | **UPDATED** | Integrated clean rounded card UI and `SocialLoginButton`. |
| `Mobile/lib/features/auth/screens/register_screen.dart` | **UPDATED** | Integrated clean form fields and consistent spacing. |
| `Mobile/lib/features/home/screens/home_screen.dart` | **UPDATED** | Replaced legacy home with Google Stitch Batch 1 UI (dynamic header, action grid, eco tips). |
| `Mobile/lib/features/home/screens/home_screen_old.dart` | **DELETED** | Removed legacy redundant home screen during project refactoring. |
| `Mobile/lib/features/home/screens/main_navigation_screen.dart` | **NEW** | Modularized main bottom navigation container into `home/` feature directory. |
| `Mobile/lib/features/deposit/screens/manual_deposit_screen.dart` | **UPDATED** | Material 3 grid category selection, weight slider, and sticky bottom summary. |
| `Mobile/lib/features/deposit/screens/checkout_screen.dart` | **UPDATED** | Replaced legacy UI with full Google Stitch checkout design; preserved blue gradient buttons. |
| `Mobile/lib/features/deposit/screens/deposit_submitted_screen.dart` | **NEW** | Success screen after checkout; `"Lacak Status Pesanan"` button routing to `OrderDetailScreen`. |
| `Mobile/lib/features/deposit/screens/scan_screen.dart` | **NEW** | Re-organized from `scan/` into modular `deposit/` feature directory. |
| `Mobile/lib/features/orders/screens/order_detail_screen.dart` | **UPDATED** | Fixed responsive status badge width; implemented full 7-Stage Status Timeline logic. |
| `Mobile/lib/features/orders/screens/driver_tracking_screen.dart` | **NEW** | Real-time driver location map view and contact card interface. |
| `Mobile/lib/core/routes/app_router.dart` | **UPDATED** | Registered all modular routes (`/checkout`, `/deposit-success`, `/orders/detail`, etc.). |
| `Mobile/lib/shared/widgets/primary_button.dart` | **UPDATED** | Added optional `IconData? icon` parameter to support action buttons with icons. |
| `Halaman-Driver/lib/screens/pickup_detail_screen.dart` | **UPDATED** | Adaptive action buttons for sequential flow (`accepted` -> `on_the_way` -> `picked_up`). |
| `Halaman-Driver/lib/screens/pickup_verification_screen.dart` | **UPDATED** | Converted to `StatefulWidget`; added actual weight input controller; button navigates to `/complete-pickup`. |
| `Halaman-Driver/lib/screens/pickup_completion_screen.dart` | **NEW** | Complete Pickup screen (`/complete-pickup`) with summary, 3-item checklist, and `validating` API update. |
| `Halaman-Driver/lib/services/api_service.dart` | **UPDATED** | Updated `updateOrderStatus()` to accept optional `{String? beratAktual}` parameter. |
| `Halaman-Driver/lib/main.dart` | **UPDATED** | Registered `/complete-pickup` route pointing to `PickupCompletionScreen`. |
| `bank_sampah/alter_db_for_mobile.sql` | **UPDATED** | Added `'validating'` to ENUM definition of `orders.status` table migration script. |
| `bank_sampah/run_migrations.php` | **UPDATED** | Executed database migration adding `validating` ENUM to local running database. |
| `bank_sampah/modules/api/orders_api.php` | **UPDATED** | Added `validating` to valid status list and notification messages; supported optional `estimasi_berat`/`berat_aktual` updates during PUT. |
| `bank_sampah/modules/api/driver_api.php` | **UPDATED** | Updated `get_active_task` query to filter `status IN ('accepted', 'on_the_way', 'picked_up')`. |

---

## 9. FILES THAT MUST NOT BE MODIFIED

The following files represent core shared utilities, established SSOT specifications, or verified backend contracts. **Do NOT modify these files without explicit team consensus:**

1. **`Mobile/lib/shared/widgets/primary_button.dart` & `bottom_navbar.dart`:**
   * *Reason:* Core UI Design System components used across 20+ screens. Unauthorized changes will cause visual regression and layout breaking across completed modules.
2. **`Mobile/lib/core/routes/app_router.dart` & `app_routes.dart`:**
   * *Reason:* Centralized routing contract for the entire Citizen application. Modifying route names or parameters will break deep links and navigation flows.
3. **`Halaman-Driver/lib/services/api_service.dart` & `constants/api_config.dart`:**
   * *Reason:* Verified HTTP communication layer for the Driver app. Handlers for authentication headers and status updates (`updateOrderStatus`) are strictly calibrated against PHP backend endpoints.
4. **`bank_sampah/config/database.php` & `run_migrations.php`:**
   * *Reason:* Database connection credentials and core schema definition scripts.
5. **SSOT Documentation (`MASTER_PROJECT_PLAN.md`, `FEATURE_INVENTORY.md`, `SCREEN_CATALOG.md`, `STITCH_PROMPTS.md`):**
   * *Reason:* Single Source of Truth for project scope, design tokens, and functional specifications. These documents are finalized and locked.

---

## 10. FILES STILL SAFE TO DEVELOP

Teammates may safely continue developing or expanding features inside the following modular directories without risking merge conflicts with the core deposit/orders workflow:

* **`Mobile/lib/features/notification/` (`notifications_screen.dart`, `notification_detail_screen.dart`):** Safe for integrating FCM push notification payload parsing and notification history pagination.
* **`Mobile/lib/features/education/` (`video_detail_screen.dart`, education articles):** Safe for adding video player controllers, article bookmarking, and eco-quiz features.
* **`Mobile/lib/features/profile/` (`profile_screen.dart`, `transfer_point_page.dart`):** Safe for implementing profile photo upload to backend, password update forms, and point transfer history lists.
* **`bank_sampah/admin.php` & `modules/api/` (New Endpoints):** Safe for building the Web Admin validation dashboard (`admin.php`), analytical charts, and reward calculation subroutines.

---

## 11. KNOWN ISSUES

1. **Web Admin Validation Panel (`admin.php`):** Currently requires UI/UX refinement to allow warehouse staff to easily filter orders with status `validating` and click "Confirm & Disperse Points" (`completed`).
2. **Real-Time GPS Tracking (`DriverTrackingScreen`):** Currently uses simulated/dummy coordinates and static map markers. Needs WebSocket or Pusher integration to listen for live driver latitude/longitude updates.
3. **Push Notification Triggers:** When `PUT modules/api/orders_api.php` updates order status, it currently inserts a record into the `notifikasi` database table. A background worker or FCM REST API call is needed to push instant native notifications to iOS/Android devices.

---

## 12. NEXT DEVELOPMENT PLAN

Recommended sequence of development milestones for the engineering team:

```
[Phase 1] Web Admin Validation Workflow (Priority: HIGH)
    ↓  Complete admin.php interface to validate incoming picked_up/validating orders and credit points.
[Phase 2] Real-Time Geolocation Sync (Priority: HIGH)
    ↓  Integrate location_permission and WebSocket stream on Driver app to broadcast lat/lng to Warga tracking screen.
[Phase 3] Firebase Cloud Messaging (FCM) Integration (Priority: MEDIUM)
    ↓  Connect backend notification triggers to FCM API for live lockscreen alerts.
[Phase 4] Reward Redemption & Transfer Points History (Priority: MEDIUM)
    ↓  Finalize UI and API endpoints for citizen point withdrawal and transfer (`transfer_point_page.dart`).
[Phase 5] End-to-End Performance & Automated QA (Priority: LOW)
    ↓  Run comprehensive widget testing, integration testing, and memory leak profiling before final production build.
```

---

## 13. GIT HANDOVER CHECKLIST

Every teammate **must** strictly follow this checklist before initiating any new code changes:

* [ ] **`git pull origin main`** — Always pull the latest synchronized branch to ensure you have the refactored modular folder structure (`lib/features/`).
* [ ] **Read `DEVELOPMENT_HANDOVER.md`** — Review the updated routes, status ENUMs, and stable file restrictions.
* [ ] **Do NOT touch Completed Screens** — Never modify `home_screen.dart`, `checkout_screen.dart`, `order_detail_screen.dart`, or `pickup_completion_screen.dart` without architectural approval.
* [ ] **Create a clean feature branch** — Branch off from `main` using descriptive naming: `git checkout -b feature/admin-validation` or `git checkout -b feature/realtime-gps`.
* [ ] **Verify locally before commit** — Always run `flutter analyze` inside both `Mobile` and `Halaman-Driver` directories to ensure 0 errors/warnings before pushing.

---

## 14. MERGE CONFLICT PREVENTION & GIT WORKFLOW

### A. Folder Boundary Isolation
To guarantee **zero merge conflicts**, the engineering team must divide work strictly along feature folder boundaries:
* **Developer A (Citizen Core & Deposit):** Works exclusively in `Mobile/lib/features/deposit/` and `Mobile/lib/features/home/`.
* **Developer B (Orders & Driver Tracking):** Works exclusively in `Mobile/lib/features/orders/`.
* **Developer C (Driver Application):** Works exclusively inside `Halaman-Driver/lib/screens/` and `Halaman-Driver/lib/services/`.
* **Developer D (Backend & Web Admin):** Works exclusively inside `bank_sampah/modules/api/` and `bank_sampah/admin.php`.

### B. Recommended Git Practices
1. **Atomic Commits:** Make small, logical commits focused on a single feature or bugfix (e.g., `feat(orders): add responsive status badge to OrderDetailScreen`).
2. **Rebase Over Merge:** When pulling upstream changes into your local feature branch, prefer `git pull --rebase origin main` to maintain a linear, clean commit history.
3. **No Simultaneous Router Edits:** If you need to add a new route to `AppRouter` (`Mobile/lib/core/routes/app_router.dart`), coordinate in the team chat first or add your route at the very end of the route map to prevent conflict markers (`<<<<<<< HEAD`).
4. **Lockfile Discipline:** If `pubspec.yaml` is modified, always commit the generated `pubspec.lock` file alongside it so all teammates run on identical dependency versions.

---
*End of Development Handover Document. Generated by Antigravity Senior Software Architect.*
