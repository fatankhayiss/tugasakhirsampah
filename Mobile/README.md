# iTrashy Mobile (Flutter)

## Konfigurasi koneksi backend

App sudah mendukung environment API melalui `dart-define`.

### Prioritas base URL
1. `API_BASE_URL` (override langsung)
2. `APP_FLAVOR` (`prod` / `staging` / `dev`)
3. fallback default internal

### Contoh menjalankan app

#### Production (default domain)
```bash
flutter run --dart-define=APP_FLAVOR=prod
```

#### Production dengan override URL langsung
```bash
flutter run --dart-define=API_BASE_URL=https://itrashy.triki.cloud/bank_sampah/
```

#### Staging
```bash
flutter run --dart-define=APP_FLAVOR=staging
```

#### Development (emulator Android)
```bash
flutter run --dart-define=APP_FLAVOR=dev
```

## Catatan
- Pastikan URL backend mengarah ke root `bank_sampah/`.
- Semua endpoint mobile berada di `modules/api/*.php`.
