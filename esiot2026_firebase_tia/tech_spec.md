# Technical Specification: IoT Dashboard Flutter - Firebase

## 1. System Overview
Aplikasi mobile berbasis Flutter untuk memantau data sensor (suhu, kelembapan) dan mengontrol aktuator (LED) secara real-time melalui Firebase Real-time Database.

## 2. Technical Stack
- **Framework:** Flutter
- **Database:** Firebase Real-time Database (RTD)
- **State Management:** StreamBuilder (Native Flutter)

## 3. Firebase Configuration & Security
- **Authentication:** Diperlukan karena aturan database adalah `auth != null`.
- **Auto-Login Logic:** Aplikasi harus melakukan autentikasi secara otomatis (hardcoded credentials) pada fungsi `initState`.
- **Credentials Placeholder:** 
  - Email: `iotia2026ti2b@gmail.com` (Sesuaikan dengan akun Firebase Anda)
  - Password: `12345678` (Sesuaikan dengan akun Firebase Anda)

## 4. Database Schema (Path Mapping)
Aplikasi harus terhubung ke path berikut di Firebase Real-time Database:
- **Sensor Data:**
  - `/esiot-db/suhu` (Type: Float/Double) - Satuan: °C
  - `/esiot-db/kelembapan` (Type: Float/Double) - Satuan: %
- **Control Data:**
  - `/esiot-db/led` (Type: Int) - Nilai: 0 (OFF) atau 1 (ON)

## 5. UI/UX Features Requirements
- **Dashboard:**
  - Menampilkan 2 kartu (Card) monitoring untuk Suhu dan Kelembapan dengan ikon/emoji yang menarik (🌡️ untuk suhu, 💧 untuk kelembapan).
  - Button interaktif untuk kontrol LED yang tersinkronisasi dengan Firebase, dengan indikator status ON/OFF.
- **Connection Status:** Indikator visual jika aplikasi berhasil terhubung ke Firebase atau sedang dalam proses autentikasi.

## 6. Dependencies (pubspec.yaml)
Aplikasi membutuhkan paket berikut:
- `firebase_core`
- `firebase_auth`
- `firebase_database`
- `google_fonts` (Opsional untuk estetika)