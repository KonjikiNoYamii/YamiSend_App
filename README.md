# yami_send — Aplikasi Klien Flutter

**yami_send** adalah aplikasi klien **Flutter** untuk **YamiSend**, digunakan untuk mengirim file dari perangkat pengirim ke server melalui jaringan lokal.

## Fitur

- Koneksi ke server melalui alamat IP di port 3000
- Verifikasi koneksi (ping)
- Upload file menggunakan file picker native
- Mendukung Android, iOS, Linux, macOS, Windows, dan Web

## Teknologi & Dependensi

| Paket | Versi | Kegunaan |
|-------|-------|----------|
| flutter | SDK | Framework UI |
| cupertino_icons | ^1.0.8 | Ikon gaya iOS |
| http | ^1.6.0 | HTTP client untuk komunikasi dengan server |
| file_picker | ^11.0.2 | Pemilih file native |
| flutter_lints | ^6.0.0 | Aturan linting (dev) |
| flutter_test | SDK | Framework pengujian (dev) |

## Struktur Kode

Aplikasi ini terdiri dari satu file utama:

```
lib/
  main.dart       # Seluruh logika dan UI aplikasi
test/
  widget_test.dart # Pengujian widget dasar
```

### main.dart

File `lib/main.dart` berisi:

- **`main()`** — Entry point, menjalankan `MyApp`.
- **`MyApp`** (StatelessWidget) — Widget root `MaterialApp` tanpa tema khusus, `home: HomePage()`.
- **`HomePage`** (StatefulWidget) — Halaman utama dengan state:
  - `ipController` — TextEditingController untuk input IP server.
  - `status` — String status koneksi/upload (default: `"Disconnected"`).
- **`_HomePageState`** — State dengan method:
  - `connectToServer()` — Mengirim GET request ke `http://<ip>:3000/ping`, menampilkan pesan respons.
  - `uploadFile()` — Membuka file picker, mengirim file sebagai multipart POST ke `http://<ip>:3000/upload`.
- **UI** — Column dengan TextField (input IP), dua ElevatedButton (CONNECT, UPLOAD FILE), dan Text status.

## Cara Menjalankan

### Prasyarat

- Flutter SDK terinstal (versi 3.44.0+)
- Perangkat/emulator terhubung

### Langkah

```bash
# Masuk ke direktori aplikasi
cd yami_send

# Install dependensi
flutter pub get

# Jalankan
flutter run
```

Untuk platform tertentu:
```bash
flutter run -d chrome      # Web
flutter run -d linux       # Linux
flutter run -d windows     # Windows
flutter run -d macos       # macOS
```

## Catatan Penting

1. **IP Server**: Pastikan server yamisend-server berjalan dan perangkat terhubung dalam jaringan yang sama.
2. **Firewall**: Pastikan port 3000 tidak diblokir oleh firewall.
3. **Android**: Untuk Android 9+, gunakan koneksi HTTP biasa (cleartext). Jika menggunakan HTTPS, sesuaikan konfigurasi.
4. **Single File**: Aplikasi ini belum dipisah ke dalam layer arsitektur terpisah (model, service, widget). Seluruh kode masih dalam satu file.
5. **State Management**: Masih menggunakan `setState()` tanpa library state management.

## Pengujian

```bash
flutter test
```

Catatan: Test saat ini (`widget_test.dart`) masih berupa boilerplate default dan belum disesuaikan dengan kode aktual.
