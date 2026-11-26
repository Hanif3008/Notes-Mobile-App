# Catatanku — Notes Mobile App

Aplikasi catatan mobile berbasis **Flutter** dengan arsitektur **Offline-First** (SQLite + sinkronisasi MockAPI), peta lokasi interaktif, reverse geocoding alamat, serta pemantauan sensor perangkat.

## Fitur Utama

- **Autentikasi & Profil Pengguna**
  - Login, registrasi, pembaruan profil, dan hapus akun terintegrasi dengan **MockAPI** (`/users`).
- **Manajemen Catatan (CRUD) & Progres**
  - Buat, ubah, cari, filter (`Semua`, `Selesai (>50%)`, `Berjalan`), urutkan, dan hapus catatan lengkap dengan slider progres kelengkapan (`0%–100%`).
- **Offline-First dengan SQLite & Sinkronisasi**
  - Penyimpanan lokal menggunakan `sqflite` (`notes_offline.db`) di perangkat mobile/native dan fallback `localStorage` untuk Flutter Web.
  - Mendukung tombol **Simpan Offline (Create/Update)** untuk menyimpan perubahan saat tidak ada koneksi, disertai badge status `Offline` dan tombol **Sinkronkan ke MockAPI** pada dashboard.
- **Peta Lokasi, GPS & Alamat Otomatis**
  - Deteksi koordinat GPS otomatis (`geolocator`) dan pemilihan titik lokasi interaktif di peta **OpenStreetMap** (`flutter_map`).
  - Konversi koordinat menjadi alamat yang mudah dibaca secara otomatis menggunakan **Nominatim Reverse Geocoding** dengan cache lokal.
- **Sensor Perangkat**
  - **Penghitung Guncangan** berbasis Accelerometer (`sensors_plus`).
  - **Kompas Interaktif** dengan animasi rotasi halus dan penunjuk arah mata angin.
  - **Giroskop** real-time (`X`, `Y`, `Z` dalam `rad/s`).

## Teknologi yang Digunakan

- **Framework:** Flutter & Dart (`^3.14.0`)
- **Backend / API:** MockAPI (`http`)
- **Database Lokal:** SQLite (`sqflite`, `path`)
- **Peta & Lokasi:** `flutter_map`, `latlong2`, `geolocator`, OpenStreetMap Nominatim
- **Sensor:** `sensors_plus`
- **UI:** `material_ui`

## Struktur Proyek

```text
lib/
├── main.dart
├── models/
│   └── note_model.dart              # Model User & Note beserta metadata sinkronisasi
├── screens/
│   ├── login_register_screen.dart   # Halaman masuk & daftar
│   ├── main_shell_screen.dart       # Navigasi utama (Catatan, Peta, Sensor, Profil)
│   ├── notes_dashboard_screen.dart  # Dashboard catatan, status offline, & sinkronisasi
│   ├── edit_note_screen.dart        # Form tambah/ubah catatan, peta, & simpan offline
│   ├── map_screen.dart              # Peta sebaran lokasi seluruh catatan
│   ├── sensor_screen.dart           # Penghitung guncangan, kompas animasi, & giroskop
│   └── profile_screen.dart          # Profil pengguna & pengaturan akun
├── services/
│   ├── mock_api_service.dart        # Klien HTTP untuk MockAPI
│   ├── local_database_service.dart  # Layanan SQLite offline & antrean sinkronisasi
│   └── geocoding_service.dart       # Reverse geocoding koordinat ke alamat
├── state/
│   └── app_state.dart               # Manajemen state aplikasi & alur sinkronisasi
├── theme/
│   └── app_theme.dart               # Tema warna & tipografi aplikasi
└── widgets/
    ├── common_widgets.dart
    └── delete_confirm_dialog.dart
```

## Cara Menjalankan

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Jalankan aplikasi:**
   - Di Android / Emulator:
     ```bash
     flutter run
     ```
   - Di Web Server:
     ```bash
     flutter run -d web-server --web-port 8080
     ```

3. **Jalankan analisis & pengujian:**
   ```bash
   flutter analyze
   flutter test
   ```
