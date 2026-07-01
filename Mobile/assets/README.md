# Asset structure — iTrashy / mobile_user

## Folder layout

```
assets/
├── images/
│   ├── auth/          # Login, register, OTP banners
│   ├── home/          # Dashboard banners, edukasi cards
│   ├── common/        # Onboarding, empty states, shared illustrations
│   └── transfer/      # Transfer point visuals
├── icons/             # Small UI icons (e-wallets, banks, social)
└── (legacy root)      # Older files — keep explicit paths in pubspec.yaml
```

## Adding a new image

1. Copy file into the correct folder (lowercase names, no spaces preferred).
2. Add constant in `lib/core/constants/app_images.dart`.
3. If the folder is new, register it in `pubspec.yaml` under `flutter: assets:`.
4. Run:

```bash
flutter pub get
flutter run
```

Use **hot restart (`R`)** or full reinstall — hot reload does **not** pick up new assets.

## Troubleshooting "Unable to load asset"

| Cause | Fix |
|-------|-----|
| `pubspec.yaml` not updated | Add folder or explicit file path, then `flutter pub get` |
| Hot reload only | Stop app → `flutter run` again |
| Stale build cache | `flutter clean` → `flutter pub get` → `flutter run` |
| Path typo / wrong case | Must match file exactly (`edukasi_1.png` ≠ `Edukasi_1.png`) |
| File with spaces | List **explicit** path in pubspec (see root legacy assets) |
| File not on disk | Verify with `dir assets\images\home` |

Verify all `AppImages.bundled` paths:

```bash
flutter test test/app_images_test.dart
```
