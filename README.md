# Rasa Nusantara - Aplikasi Resep Flutter

Aplikasi resep yang dibangun dengan Flutter menggunakan pattern ContentProvider untuk manajemen data dan SharedPreferences untuk penyimpanan konfigurasi.

## Fitur Utama

- ✅ **ContentProvider Pattern** - Implementasi pattern serupa ContentProvider Android untuk akses data
- ✅ **SharedPreferences** - Penyimpanan data konfigurasi dan preferensi pengguna
- ✅ **Local Database** - SQLite untuk penyimpanan data lokal
- ✅ **REST API Integration** - Sinkronisasi dengan backend Node.js
- ✅ **User Authentication** - Login dan registrasi user
- ✅ **CRUD Operations** - Create, Read, Update, Delete resep
- ✅ **Image Picker** - Upload gambar untuk resep
- ✅ **Offline Support** - Aplikasi tetap berfungsi tanpa internet

## Implementasi ContentProvider Pattern

### 1. RecipeProvider (`lib/providers/recipe_provider.dart`)
Mengelola akses data resep dengan fitur:
- **Local-First Strategy**: Data disimpan lokal terlebih dahulu, kemudian sinkron ke server
- **CRUD Operations**: Add, update, delete, dan load resep
- **Error Handling**: Penanganan error yang konsisten
- **Loading States**: Indikator loading untuk UX yang lebih baik

### 2. UserProvider (`lib/providers/user_provider.dart`)
Mengelola data user dengan fitur:
- **Authentication**: Login dan registrasi
- **User Session**: Manajemen sesi user
- **Local Storage**: Penyimpanan data user lokal

### 3. AppProvider (`lib/providers/app_provider.dart`)
Provider utama yang mengkoordinasikan:
- **App Initialization**: Inisialisasi aplikasi dan cek status login
- **Provider Coordination**: Koordinasi antara RecipeProvider dan UserProvider
- **SharedPreferences Integration**: Integrasi dengan SharedPreferences

## Struktur Data

### SharedPreferences Keys
- `userId`: ID user yang sedang login
- `username`: Username user yang sedang login

### Database Schema
```sql
-- Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL
);

-- Recipes table
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  ingredients TEXT NOT NULL,
  steps TEXT NOT NULL,
  imagePath TEXT,
  userId INTEGER,
  FOREIGN KEY (userId) REFERENCES users (id)
);
```

## Cara Kerja ContentProvider Pattern

1. **Data Access Layer**: Semua akses data melalui provider
2. **Local-First**: Data disimpan lokal terlebih dahulu
3. **Sync Strategy**: Sinkronisasi dengan server secara background
4. **Error Recovery**: Fallback ke data lokal jika server tidak tersedia
5. **State Management**: Menggunakan Provider untuk state management

## Keuntungan Implementasi

### 1. **Separation of Concerns**
- Data access logic terpisah dari UI
- Mudah untuk testing dan maintenance

### 2. **Offline Support**
- Aplikasi tetap berfungsi tanpa internet
- Data tersimpan lokal dengan SQLite

### 3. **Consistent Data Access**
- Interface yang konsisten untuk semua operasi data
- Error handling yang seragam

### 4. **Scalability**
- Mudah menambah fitur baru
- Struktur yang modular

## Setup dan Instalasi

### Prerequisites
- Flutter SDK
- Node.js (untuk backend)
- SQLite

### Backend Setup
```bash
cd backend
npm install
node index.js
```

### Flutter Setup
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  sqflite: ^2.3.3
  path_provider: ^2.1.3
  shared_preferences: ^2.2.3
  provider: ^6.1.2
  image_picker: ^1.1.1
  path: ^1.9.0
  http: ^1.1.0
```

## API Endpoints

- `POST /api/register` - Registrasi user
- `POST /api/login` - Login user
- `GET /api/recipes?userId={id}` - Ambil resep user
- `POST /api/recipes` - Tambah resep baru
- `PUT /api/recipes/{id}` - Update resep
- `DELETE /api/recipes/{id}` - Hapus resep
- `GET /api/all-recipes` - Ambil semua resep

## Screenshots

[Gambar aplikasi akan ditambahkan di sini]

## Kontribusi

Silakan buat pull request untuk kontribusi atau laporkan bug melalui issues.

## License

MIT License
