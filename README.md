# MyPortfolio Mobile (`myportofolio_mobile`)

[![CI](https://github.com/kapitrafachriza-byte/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/kapitrafachriza-byte/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile multiplatform berbasis **Flutter** untuk portofolio pribadi **Kapitra Fachriza Utomo**, dibangun sebagai klien mobile pendamping yang terintegrasi dengan REST API Django ([`myportofolio`](https://github.com/kapitrafachriza-byte/myportofolio)).

- **Nama:** Kapitra Fachriza Utomo
- **NPM:** `2506623231`
- **Kelas:** PBP E
- **Repositori Mobile:** https://github.com/kapitrafachriza-byte/myportofolio_mobile
- **Repositori Web (Django & DRF):** https://github.com/kapitrafachriza-byte/myportofolio
- **URL Backend Deploy (PWS):** https://kapitra-fachriza-myportofolio.pws.cs.ui.ac.id

---

## Fitur & Struktur Saat Ini

1. **Halaman Beranda Modular ([`lib/screens/menu.dart`](lib/screens/menu.dart))**:
   - **Kartu Identitas Pemilik (`InfoCard`)**: Menampilkan NPM, Nama Lengkap, dan Kelas dengan tinggi dan lebar kartu yang simetris (`IntrinsicHeight` + `Expanded`).
   - **Kisi Menu Aksi Portofolio ([`ItemCard`](lib/widgets/project_card.dart))**: Menampilkan 5 tombol interaktif (*Lihat Proyek*, *Tambah Proyek*, *Lihat Experience*, *Tambah Experience*, dan *Logout*) dengan warna latar unik per kartu, notifikasi `SnackBar`, serta route guard autentikasi untuk operasi tulis.
   - **Tata Letak Responsif**: Menggunakan `SingleChildScrollView`, `ConstrainedBox(maxWidth: 720)`, dan `LayoutBuilder` agar bebas dari *overflow* pada layar sempit maupun lebar.
2. **Menu Navigasi Drawer & Route Guard ([`lib/widgets/left_drawer.dart`](lib/widgets/left_drawer.dart), [`lib/widgets/auth_guard.dart`](lib/widgets/auth_guard.dart))**:
   - Menyediakan navigasi konsisten untuk **Home**, **Projects** (publik), **Add Project** (terautentikasi), **Experiences** (publik), **Add Experience** (terautentikasi), serta **Login** / **Logout** reaktif terhadap `AuthState`.
3. **Integrasi Backend DRF, Serialisasi JSON, & Autentikasi Token**:
   - **Model `@JsonSerializable` ([`lib/models/project.dart`](lib/models/project.dart), [`lib/models/experience.dart`](lib/models/experience.dart))**: Memetakan JSON snake_case DRF secara otomatis melalui `json_serializable` dan `build_runner`, mengecualikan field *read-only* server dari body `POST`, serta menyediakan nilai default aman untuk field nullable.
   - **Layanan Jaringan & State ([`lib/services/api_client.dart`](lib/services/api_client.dart), [`lib/services/auth_state.dart`](lib/services/auth_state.dart))**: Menyediakan `getProjects`, `createProject`, `getExperiences`, `createExperience`, `deleteExperience`, `obtainToken`, dan `logout` melalui `MultiProvider`.
   - **Layar Daftar, Detail, & Form Terautentikasi**:
     - **Projects**: `ProjectListScreen`, `ProjectDetailScreen`, dan `ProjectFormPage`.
     - **Experiences**: `ExperienceListScreen` (`FutureBuilder`, `RefreshIndicator`, Retry, FAB tambah), `ExperienceDetailScreen` (menampilkan seluruh field + aksi hapus terautentikasi), dan `ExperienceFormPage` (`ensureLoggedIn`, validasi lengkap, penanganan `401`).
4. **CI/CD GitHub Actions ([`.github/workflows/main.yaml`](.github/workflows/main.yaml))**:
   - Menjalankan pipeline otomatis (`build` via `very_good_workflows` + `build_apk` untuk menghasilkan artefak `app-release-apk`).

### Struktur Berkas Utama

```text
myportofolio_mobile/
├── .github/workflows/
│   └── main.yaml                  # Pipeline CI/CD (very_good_workflows + build_apk)
├── lib/
│   ├── models/
│   │   ├── experience.dart        # Model JSON Experience (@JsonSerializable)
│   │   └── project.dart           # Model JSON Project (@JsonSerializable)
│   ├── screens/
│   │   ├── experience_detail_screen.dart # Detail Experience + aksi Delete terautentikasi
│   │   ├── experience_form.dart   # Form tambah Experience (POST /api/v1/experiences/)
│   │   ├── experience_list_screen.dart   # Daftar Experience publik (FutureBuilder)
│   │   ├── login_screen.dart      # Halaman login token DRF
│   │   ├── menu.dart              # Halaman beranda MyHomePage & InfoCard
│   │   ├── project_detail_screen.dart    # Detail Project
│   │   ├── project_form.dart      # Form tambah Project (POST /api/v1/projects/)
│   │   └── project_list_screen.dart      # Daftar Project publik (FutureBuilder)
│   ├── services/
│   │   ├── api_client.dart        # HTTP client REST API DRF
│   │   └── auth_state.dart        # Manajemen token session (ChangeNotifier)
│   ├── widgets/
│   │   ├── auth_guard.dart        # Guard ensureLoggedIn(context)
│   │   ├── left_drawer.dart       # Drawer navigasi samping
│   │   └── project_card.dart      # Model ItemHomepage & kartu aksi ItemCard
│   ├── config.dart                # Konfigurasi API_BASE_URL (--dart-define)
│   └── main.dart                  # Entry point aplikasi & MultiProvider
├── test/
│   └── widget_test.dart           # Unit & widget tests (MockClient, navigasi, form, CI)
├── analysis_options.yaml
└── pubspec.yaml
```

---

## Setup & Menjalankan Proyek

### Prasyarat
- **Flutter SDK** (diuji lokal pada versi `3.47.9` / CI pada `3.50.1`, Dart `3.13+`) terdaftar pada `PATH`.
- **Backend Django (`myportofolio`)** berjalan secara lokal (`python manage.py runserver`) dari repositori [`https://github.com/kapitrafachriza-byte/myportofolio`](https://github.com/kapitrafachriza-byte/myportofolio) atau URL ter-deploy.
- **Google Chrome** (web) atau **Android Emulator / Perangkat Fisik**.

### Langkah Menjalankan Lokal

```powershell
# 1. Clone repositori Flutter & unduh dependensi
git clone https://github.com/kapitrafachriza-byte/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get

# 2. Generate kode serialisasi JSON (*.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Jalankan backend Django di terminal terpisah (port 8000)
# python manage.py runserver

# 4a. Jalankan di Google Chrome terhadap backend lokal
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000

# 4b. Jalankan di Emulator Android (otomatis memakai default http://10.0.2.2:8000)
flutter run

# 4c. Jalankan terhadap backend yang sudah di-deploy
flutter run -d chrome --dart-define=API_BASE_URL=https://kapitra-fachriza-myportofolio.pws.cs.ui.ac.id
```

### Analisis Kode, Formatting, & Unit Testing

```powershell
# Memeriksa format kode sesuai standar CI
dart format --output=none --set-exit-if-changed lib test

# Memeriksa linter & aturan sintaks Dart
flutter analyze lib test

# Menjalankan unit & widget tests
flutter test
```

---

## Progres Mingguan

- **Tutorial 08 (Basic Flutter):** Instalasi Flutter SDK, verifikasi `flutter doctor`, inisialisasi proyek `myportofolio_mobile`, pemisahan `menu.dart` dari `main.dart`, penerapan tema Material 3 (`ColorScheme.fromSeed`), komponen dasar `InfoCard`, `ItemHomepage`, `ItemCard`, serta interaksi `SnackBar`.
- **Individual Assignment 7 (Basic Flutter):** Kustomisasi penuh identitas pribadi di `InfoCard`, penyesuaian menu aksi portofolio berbasis modul *Experience* dengan warna latar unik per kartu tanpa percabangan berulang, peningkatan simetri dan responsivitas layout (`IntrinsicHeight`, `Expanded`, `ConstrainedBox`), penambahan Dart doc comments, pembaruan widget test termasuk uji layar sempit 360px, serta dokumentasi & jawaban reflektif di `README.md`.
- **Tutorial 09 (Navigation, Layouts, Forms & Input Elements):** Pembuatan `LeftDrawer`, halaman `ProjectFormPage` lengkap dengan input form & `AlertDialog`, navigasi `ItemCard` menggunakan `Navigator.push()`, serta refactoring direktori menjadi `lib/screens/` dan `lib/widgets/`.
- **Individual Assignment 8 (Navigation, Layouts, Forms & Input Elements):** Pembuatan halaman baru [`ExperienceFormPage`](lib/screens/experience_form.dart) sesuai model Django `Experience` (input judul, kategori dropdown, `showDatePicker()` tanggal selesai, checkbox *Ongoing*, deskripsi, dan URL thumbnail opsional), validasi lengkap (tolak spasi kosong, panjang maksimal, format URL), penambahan kartu aksi **Tambah Experience** dan opsi drawer **Add Experience**, konsistensi `Theme.of(context).colorScheme.primary` lintas halaman, serta widget test menyeluruh.
- **Tutorial 10 (Backend Integration, Authentication & CI/CD):** Pengaktifan `TokenAuthentication`, `django-cors-headers`, dan endpoint `/api/v1/auth/token/` + `/api/v1/auth/logout/` pada backend Django; pembuatan model `@JsonSerializable` (`Project`), `ApiClient`, `AuthState`, `MultiProvider`, `LoginScreen`, `ensureLoggedIn`, `ProjectListScreen`, `ProjectDetailScreen`, migrasi `material_ui`, serta pipeline GitHub Actions CI/CD (`very_good_workflows` + `build_apk`).
- **Individual Assignment 9 (Backend Integration untuk Model `Experience`):** Penambahan model `@JsonSerializable` [`Experience`](lib/models/experience.dart), perluasan [`ApiClient`](lib/services/api_client.dart) (`getExperiences`, `createExperience`, dan fitur ekstra `deleteExperience`), pembuatan [`ExperienceListScreen`](lib/screens/experience_list_screen.dart) & [`ExperienceDetailScreen`](lib/screens/experience_detail_screen.dart), refactor [`ExperienceFormPage`](lib/screens/experience_form.dart) untuk mengirim `POST /api/v1/experiences/` terautentikasi lengkap dengan penanganan `401`, integrasi kartu **Lihat Experience** & drawer **Experiences**, serta pengujian `MockClient` menyeluruh.

---

### Tugas 7

1. **Jelaskan apa yang dimaksud dengan *widget tree* pada Flutter dan bagaimana hubungan induk-anak (*parent-child*) bekerja antar-widget!**

   - **Pengertian *Widget Tree*:**  
     Di Flutter, hampir seluruh elemen antarmuka—mulai dari tata letak (*padding*, *row*, *column*), tampilan teks, ikon, hingga konfigurasi tema dan navigasi—adalah **widget**. *Widget tree* adalah struktur pohon hierarkis deklaratif yang menggambarkan bagaimana widget-widget tersebut tersusun dan bersarang (*nested*) satu sama lain untuk membentuk seluruh tampilan aplikasi (misalnya: `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → `Column` → `Row` → `InfoCard` → `Card` → `Text`).
   - **Cara Kerja Hubungan Induk–Anak (*Parent–Child*):**
     - **Komposisi dan Pewarisan Konteks:** Widget induk (*parent*) membungkus satu anak (`child`) atau banyak anak (`children`), sekaligus dapat menyediakan konteks bersama (seperti tema dari `MaterialApp` atau `ScaffoldMessenger` dari `Scaffold`) agar bisa diakses oleh seluruh keturunan di bawahnya lewat `BuildContext`.
     - **Mekanisme Layout (*Constraints Go Down, Sizes Go Up, Parent Sets Position*):** Ketika fase layout berlangsung, induk memberikan batasan ukuran (*constraints*, yakni lebar dan tinggi minimum/maksimum) ke bawah kepada anaknya. Anak menentukan ukurannya sendiri sesuai batasan tersebut lalu melaporkannya kembali ke induk. Terakhir, induk menentukan posisi koordinat tempat anak tersebut digambar di layar. Contohnya pada kode proyek ini, `Expanded` membagi lebar horizontal `Row` secara merata lalu memaksa tiap `InfoCard` mengisi lebar tersebut, sementara `IntrinsicHeight` menyelaraskan tinggi seluruh anak di dalam `Row`.

2. **Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   Berikut adalah seluruh widget (kustom maupun bawaan Flutter) yang digunakan pada [`lib/main.dart`](lib/main.dart) dan [`lib/menu.dart`](lib/menu.dart):

   **Widget Kustom:**
   - **`MyApp`** (`StatelessWidget`): Widget *root* aplikasi yang menginisialisasi `MaterialApp` dan tema global.
   - **`MyHomePage`** (`StatelessWidget`): Widget halaman utama yang menyimpan data profil pemilik dan daftar `items`, serta menyusun tata letak beranda portofolio.
   - **`InfoCard`** (`StatelessWidget`): Komponen kartu terpakai ulang (*reusable widget*) untuk menampilkan sepasang judul dan isi informasi pemilik portofolio (`NPM`, `Name`, `Class`).
   - **`ItemCard`** (`StatelessWidget`): Komponen kartu tombol aksi interaktif yang menampilkan ikon, label, warna latar unik dari `ItemHomepage`, dan memicu `SnackBar` saat ditekan.

   **Widget Bawaan Flutter:**
   - **`MaterialApp`**: Widget pembungkus aplikasi Material Design yang mengatur tema, judul aplikasi, navigasi dasar, lokalisasi, dan dukungan `ScaffoldMessenger`.
   - **`Scaffold`**: Menyediakan kerangka struktur visual standar halaman Material Design (slot `appBar`, `body`, dan area tampil `SnackBar`).
   - **`AppBar`**: Menampilkan bilah judul (*header*) pada bagian paling atas halaman bertuliskan `'MyPortfolio'`.
   - **`SingleChildScrollView`**: Membuat konten halaman dapat digulir secara vertikal apabila tinggi layar perangkat lebih kecil dari tinggi total konten.
   - **`Center`**: Memposisikan widget anak di tengah area ruang yang tersedia dari induknya.
   - **`ConstrainedBox`**: Membatasi ukuran dimensi widget anak (digunakan untuk `maxWidth: 720` agar tampilan di layar desktop tetap proporsional dan tidak terlalu melebar).
   - **`Padding`**: Memberikan jarak ruang kosong di sekeliling widget anak (misal `EdgeInsets.all(16.0)` di tepi halaman dan jarak atas teks sambutan).
   - **`Column`**: Menyusun daftar widget anak (`children`) secara vertikal dari atas ke bawah.
   - **`IntrinsicHeight`**: Menyelaraskan tinggi maksimal widget-widget anak di dalam `Row` sehingga ketiga kartu `InfoCard` tampil memiliki tinggi seragam.
   - **`Row`**: Menyusun daftar widget anak secara horizontal dari kiri ke kanan (untuk meletakkan 3 `InfoCard` secara sejajar).
   - **`Expanded`**: Memaksa widget anak di dalam `Row` untuk membagi sisa ruang horizontal secara proporsional agar ketiga `InfoCard` memiliki lebar yang sama persis.
   - **`SizedBox`**: Memberikan jarak kosong tetap antar-komponen (lebar `8.0` antar-`InfoCard`, tinggi `16.0` di bawah `Row`, dan tinggi `6` antara ikon dan teks di `ItemCard`).
   - **`Text`**: Menampilkan string teks ke layar beserta pengaturan gaya (`TextStyle`), ukuran font, ketebalan, warna, dan perataan teks (`TextAlign.center`).
   - **`GridView.count`**: Menampilkan kumpulan `ItemCard` dalam tata letak kisi terstruktur sebanyak 3 kolom (`crossAxisCount: 3`) dengan rasio aspek dan spasi antar-kartu yang seragam.
   - **`Card`**: Widget permukaan Material yang memberi efek bayangan (*elevation*) dan sudut membulat untuk tiap `InfoCard`.
   - **`Container`**: Pembungkus serbaguna untuk mengatur `padding` internal di dalam `InfoCard` dan `ItemCard`.
   - **`Material`**: Menyediakan permukaan Material pada `ItemCard` yang menerima warna latar dinamis (`item.color`), bayangan (`elevation: 3.0`), serta sudut membulat (`borderRadius`) sekaligus mendukung efek riak (*ripple*) dari `InkWell`.
   - **`InkWell`**: Menambahkan perilaku responsif sentuhan (*onTap*) beserta animasi efek riak (*ink splash*) pada `ItemCard`.
   - **`Icon`**: Menampilkan ikon grafis Material (`Icons.work_outline`, `Icons.add_circle_outline`, `Icons.logout`) di dalam tombol.
   - **`Flexible`**: Mengizinkan teks label di dalam `Column` pada `ItemCard` menyesuaikan ruang vertikal/wrapping yang tersedia secara aman tanpa menyebabkan *overflow*.
   - **`SnackBar`**: Widget pesan umpan balik sementara di bagian bawah layar (dipicu melalui `ScaffoldMessenger.of(context)`) yang menampilkan `"Kamu telah menekan tombol [Nama Tombol]!"`.

3. **Apa fungsi dari widget `MaterialApp`? Jelaskan mengapa widget ini umumnya digunakan sebagai *root widget* pada aplikasi Flutter!**

   - **Fungsi `MaterialApp`:**  
     `MaterialApp` adalah widget konfigurasi tingkat aplikasi yang menyediakan seluruh infrastruktur Material Design untuk aplikasi Flutter. Di antaranya mencakup:
     1. **Pengaturan Tema Global (`theme` & `ThemeData`)**: Mendistribusikan palet warna (`ColorScheme`), tipografi, dan gaya komponen ke seluruh widget di aplikasi melalui `Theme.of(context)`.
     2. **Manajemen Navigasi & Rute (`home`, `routes`, `Navigator`)**: Mengelola tumpukan halaman (*route stack*) untuk berpindah antar-layar.
     3. **Dukungan Utilitas Sistem & Aksesibilitas**: Menyediakan `MediaQuery` (informasi dimensi layar, orientasi, padding sistem), `Localizations` (bahasa & arah teks LTR/RTL), serta `ScaffoldMessenger` agar `SnackBar` bekerja secara konsisten.
     4. **Identitas Aplikasi**: Menentukan `title` aplikasi di pengalih aplikasi OS/tab browser dan mengatur debug banner.
   - **Mengapa Dijadikan *Root Widget*:**  
     Widget seperti `Scaffold`, `AppBar`, `Text`, dan `InkWell` bergantung pada konteks global (tema, arah teks, lokalisasi, `Navigator`, dan `Overlay`) yang disediakan oleh `MaterialApp`. Dengan meletakkan `MaterialApp` di puncak pohon (`MyApp`), seluruh halaman dan komponen di bawahnya otomatis berada dalam satu payung konteks Material Design yang konsisten tanpa harus dikonfigurasi ulang pada setiap halaman.

4. **Jelaskan perbedaan antara `StatelessWidget` dan `StatefulWidget`! Kapan kita sebaiknya memilih `StatelessWidget` dan kapan harus menggunakan `StatefulWidget`?**

   - **Perbedaan Utama:**
     - **`StatelessWidget`**: Widget yang bersifat *immutable* (tetap) setelah dibuat dan **tidak memiliki objek `State` internal** yang dapat berubah selama siklus hidupnya. Widget ini hanya memiliki satu metode `build(BuildContext context)` yang merender UI berdasarkan konfigurasi parameter constructor (`final` fields) atau data dari `BuildContext` (misal `Theme`). Jika tampilannya harus berubah, induknya harus membangun ulang instance `StatelessWidget` tersebut dengan argumen baru.
     - **`StatefulWidget`**: Widget yang terhubung dengan sebuah objek **`State<T>` terpisah yang bersifat *mutable***. Di dalam kelas `State`, kita dapat menyimpan data yang berubah-ubah seiring waktu dan memicu pembaruan tampilan secara lokal lewat pemanggilan metode `setState(() { ... })`. Widget ini juga memiliki metode siklus hidup (*lifecycle*) seperti `initState()`, `didUpdateWidget()`, dan `dispose()`.
   - **Kapan Memilih Masing-masing:**
     - **Gunakan `StatelessWidget`** ketika bagian antarmuka sepenuhnya bergantung pada data awal atau konfigurasi dari induknya dan tidak perlu mengubah nilai internalnya sendiri akibat interaksi pengguna—seperti `MyHomePage`, `InfoCard`, dan `ItemCard` pada proyek ini (bahkan saat `SnackBar` muncul, `ItemCard` tidak mengubah state internal dirinya melainkan meminta `ScaffoldMessenger` menampilkan pesan sementara). `StatelessWidget` juga lebih ringan karena tidak mengalokasikan objek `State`.
     - **Gunakan `StatefulWidget`** ketika antarmuka perlu menyimpan dan memutakhirkan data internal secara dinamis di layar yang sama—misalnya halaman formulir input (`TextEditingController`), angka penghitung (*counter*), status *loading* dan hasil pemanggilan API asinkron (seperti saat nanti menghubungkan aplikasi ini ke API DRF), animasi, atau kontrol tab/checkbox.

5. **Apa itu `BuildContext` dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode `build`?**

   - **Pengertian `BuildContext`:**  
     `BuildContext` adalah sebuah *handle* (pegangan referensi) yang merepresentasikan **lokasi spesifik suatu widget di dalam *Element Tree* / *widget tree***. Setiap widget memiliki `BuildContext`-nya masing-masing yang dikelola oleh framework Flutter saat elemen widget tersebut dipasang ke pohon UI.
   - **Mengapa Penting di Flutter:**  
     Dalam struktur pohon widget yang bersarang dalam (*deeply nested*), widget anak sering membutuhkan data konfigurasi global atau layanan dari widget leluhurnya (*ancestor*), seperti warna tema, ukuran layar, atau navigasi. Tanpa `BuildContext`, developer harus meneruskan data-data tersebut secara manual satu per satu lewat parameter constructor di setiap tingkat (*prop drilling*). `BuildContext` memungkinkan komunikasi lintas-lapisan dari bawah ke atas secara efisien (kompleksitas O(1) menggunakan lookup tabel `InheritedWidget`).
   - **Penggunaan di Dalam Metode `build(BuildContext context)`:**  
     Di dalam metode `build`, parameter `context` digunakan untuk mencari dan membaca layanan dari widget leluhur terdekat, contohnya pada proyek ini:
     - `Theme.of(context).colorScheme.primary` pada `MyHomePage` untuk mengambil warna utama tema `MaterialApp` bagi latar `AppBar`.
     - `ScaffoldMessenger.of(context)` pada `ItemCard` untuk menemukan `ScaffoldMessenger` terdekat di pohon dan memerintahkannya menampilkan `SnackBar`.

6. **Jelaskan konsep *hot reload* di Flutter dan apa perbedaannya dengan *hot restart*! Kapan kita tidak bisa hanya mengandalkan *hot reload* dan harus melakukan *hot restart* atau *full restart*?**

   - **Konsep *Hot Reload* (`r`):**  
     Pada mode pengembangan (*debug*), Flutter menggunakan kompilasi **Just-In-Time (JIT)**. Saat *hot reload* dijalankan, Flutter hanya mengompilasi berkas kode Dart yang berubah dan menyuntikkannya langsung ke dalam Dart Virtual Machine (VM) yang sedang berjalan. Setelah itu, Flutter membangun ulang *widget tree* (`build()`), tetapi **tetap mempertahankan *state* aplikasi saat itu di memori** (misal posisi scroll, isi teks form, atau angka state tetap utuh) dalam hitungan milidetik.
   - **Perbedaan dengan *Hot Restart* (`R`):**  
     *Hot restart* juga menyuntikkan kode Dart terbaru ke Dart VM, tetapi **menghancurkan dan mengatur ulang (*reset*) seluruh *state* aplikasi** di memori, lalu mengeksekusi ulang aplikasi dari fungsi `main()`. Prosesnya sedikit lebih lama dibanding *hot reload*, tetapi jauh lebih cepat daripada kompilasi penuh.
   - **Kapan *Hot Reload* Tidak Cukup dan Harus *Hot Restart* / *Full Restart*:**
     - **Harus *Hot Restart*:**
       1. Perubahan pada kode di dalam fungsi `main()` (misalnya mengganti *root widget* atau inisialisasi awal sebelum `runApp`).
       2. Perubahan tipe widget antara `StatelessWidget` menjadi `StatefulWidget` atau sebaliknya (seperti mengubah `MyHomePage` pada tutorial ini).
       3. Perubahan pada inisialisasi variabel global, properti `static`, atau kode di dalam `initState()`.
       4. Perubahan deklarasi `enum` atau struktur kelas yang tidak kompatibel dengan objek hidup di memori.
     - **Harus *Full Restart* (hentikan dan jalankan ulang `flutter run`):**
       1. Menambahkan atau memperbarui dependensi/plugin eksternal pada `pubspec.yaml` atau aset baru (gambar/font).
       2. Mengubah berkas kode atau konfigurasi native platform (`android/`, Gradle, `AndroidManifest.xml`, `ios/`, dll.).

---

### AI Disclosure (Tugas 7)

Saya menggunakan **Google Antigravity (model Gemini 3.8 Flash HIGH / Claude-tier reasoning)** sebagai asisten *pair-programming* selama pengerjaan Tutorial 08 hingga Individual Assignment 7.

**Strategi Prompting & Pengerjaan Bertahap:**
- Meminta AI menyusun **rencana implementasi (*plan-first workflow*)** di awal untuk memetakan kesesuaian dengan seluruh rubrik Tugas 7, memverifikasi pilihan desain menu portofolio (`Experience`), lalu mengeksekusinya dalam 2 tahap *commit & push* terpisah (Tahap 1: pembaruan kode & widget test; Tahap 2: dokumentasi lengkap & jawaban reflektif).

**Bagian yang Dibantu AI:**
- Setup awal environment Flutter SDK di Windows (penambahan `C:\Users\kapit\dev\flutter\bin` ke User `PATH` serta instalasi ekstensi VS Code `dart-code.flutter` dan `dart-code.dart-code`).
- Implementasi atribut `final Color color` pada model `ItemHomepage` dengan warna unik kontras serta pembaruan widget `ItemCard` dan `SnackBar` di `lib/menu.dart`.
- Penulisan dokumentasi Dart (`///`) dan pembaruan `test/widget_test.dart` (pengecekan tinggi seragam `InfoCard`, keunikan 3 warna kartu, verifikasi teks `SnackBar`, dan simulasi viewport ponsel 360×800).
- Penyusunan dokumentasi proyek dan penulisan jawaban reflektif pada `README.md`.

**Keterbatasan AI & Perbaikan Manual / Iterasi yang Dilakukan:**
1. **Penemuan *RenderFlex Overflow* pada Layar Ponsel Sempit (360px):**
   - Pada awalnya, kode yang dihasilkan menggunakan `GridView.count` bawaan tutorial (`padding: EdgeInsets.all(20)`, rasio default `1.0`, dan `Icon` 30px) tanpa memperhitungkan label yang lebih panjang seperti `"Lihat Experience"` dan `"Tambah Experience"`. Ketika diuji pada simulasi layar `Size(360, 800)` di `widget_test.dart`, muncul galat *RenderFlex overflow* sebesar 2.7px hingga 43px.
   - *Perbaikan:* Menyesuaikan `padding` horizontal `GridView.count`, menetapkan `childAspectRatio: 0.9`, membungkus `Text` dengan `Flexible`, menggunakan `mainAxisSize: MainAxisSize.min`, serta membatasi lebar desktop dengan `ConstrainedBox(maxWidth: 720)` hingga seluruh pengujian lolos tanpa overflow.
2. **Peringatan Linter `prefer_const_constructors_in_immutables`:**
   - Setelah menjadikan `items` sebagai `const List`, `flutter analyze` memunculkan info lint karena konstruktor `MyHomePage` belum ditandai `const`. Dilakukan perbaikan pada deklarasi `const MyHomePage({super.key})` di `lib/menu.dart` serta pemanggilannya di `lib/main.dart` hingga `flutter analyze` menghasilkan `No issues found!`.
3. **Kendala Sesi `PATH` Terminal & Jendela Debug Chrome Windows:**
   - Sesi PowerShell yang sudah terbuka sebelum modifikasi `PATH` belum mengenali perintah `flutter`, dan jendela Chrome debug sempat tersembunyi di balik IDE sebagai jendela terpisah. Hal ini diverifikasi melalui pengecekan proses aktif, refresh `$env:Path`, dan verifikasi server lokal di `localhost`.

---

### Tugas 8

1. **Jelaskan perbedaan antara `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`. Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Jelaskan juga bagaimana opsi Home di drawer membawa pengguna kembali ke halaman utama.**

   - **Perbedaan Ketiga Metode `Navigator`:**
     - **`Navigator.push()`:** Menambahkan (*push*) route baru ke puncak tumpukan navigasi (*route stack*) tanpa menghapus halaman sebelumnya di bawahnya. Pengguna dapat kembali ke halaman sebelumnya menggunakan tombol **Back** sistem/browser atau `Navigator.pop()`.
     - **`Navigator.pushReplacement()`:** Menghapus route yang sedang aktif di puncak tumpukan dan langsung menggantinya dengan route baru. Hal ini mencegah tumpukan route terus bertambah berulang kali saat berpindah antarhalaman melalui menu navigasi global.
     - **`Navigator.pop()`:** Menghapus route paling atas dari tumpukan navigasi untuk kembali ke route sebelumnya yang berada tepat di bawahnya (atau menutup widget berbasis route seperti `AlertDialog`).
   - **Metode pada Kartu Aksi & Opsi Home di Drawer:**
     - Untuk membuka formulir dari kartu aksi (`ItemCard` pada [`lib/widgets/project_card.dart`](lib/widgets/project_card.dart)), digunakan **`Navigator.push()`** menuju `ProjectFormPage` atau `ExperienceFormPage`. Dengan cara ini, halaman beranda tetap ada di bawah stack sehingga tombol kembali bawaan perangkat dapat mengembalikan pengguna ke beranda.
     - Sementara itu, opsi **Home** di [`LeftDrawer`](lib/widgets/left_drawer.dart) memanggil **`Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage()))`**. Panggilan ini mengganti halaman form yang sedang tampil (beserta overlay drawer) langsung dengan `MyHomePage`, sehingga pengguna kembali ke halaman utama dengan tumpukan navigasi yang tetap bersih.

2. **Bagaimana susunan `Scaffold`, `AppBar`, dan `Drawer` membantu menjaga struktur halaman tetap konsisten? Berikan satu contoh penggunaan warna tema portofolio di lebih dari satu halaman.**

   - **Konsistensi Struktur Melalui `Scaffold`, `AppBar`, dan `Drawer`:**
     - **`Scaffold`** menyediakan kerangka tata letak Material Design yang seragam pada setiap halaman (`MyHomePage`, `ProjectFormPage`, dan `ExperienceFormPage`), menempatkan slot bilah atas (`appBar`), panel navigasi samping (`drawer`), area konten utama (`body`), serta konteks tampil `SnackBar`.
     - **`AppBar`** menjaga konsistensi identitas visual di bagian teratas layar (judul halaman, tinggi bar standar, ikon putih kontras, serta tombol *hamburger* pembuka drawer otomatis).
     - **`Drawer` (`const LeftDrawer()`)** diekstrak menjadi satu widget terpisah yang dapat dipakai ulang (*reusable*) di seluruh halaman. Pengguna selalu menemukan menu navigasi yang identik (**Home**, **Add Project**, **Add Experience**) tanpa duplikasi kode antarhalaman.
   - **Contoh Penggunaan Warna Tema di Lebih dari Satu Halaman:**
     - Warna utama tema yang diturunkan dari `ColorScheme.fromSeed(seedColor: Colors.indigo)` pada `MyApp` (`lib/main.dart`) diakses secara terpusat melalui **`Theme.of(context).colorScheme.primary`** pada banyak komponen dan halaman sekaligus:
       1. Latar `AppBar` di [`MyHomePage`](lib/screens/menu.dart).
       2. Latar `AppBar` dan tombol `Save` di [`ProjectFormPage`](lib/screens/project_form.dart).
       3. Latar `AppBar` dan tombol `Simpan` di [`ExperienceFormPage`](lib/screens/experience_form.dart).
       4. Latar `DrawerHeader` pada [`LeftDrawer`](lib/widgets/left_drawer.dart).

3. **Mengapa tata letak tersebut dipilih untuk formulir? Jelaskan peran widget pengatur jarak dan widget penggulir ketika ruang layar terbatas.**

   - **Alasan Pemilihan Tata Letak (`Form` → `SingleChildScrollView` → `Center` → `ConstrainedBox(maxWidth: 720)` → `Padding` → `Column`):**
     - Formulir secara alami terdiri atas deretan input berurutan dari atas ke bawah sehingga `Column` dengan `crossAxisAlignment: CrossAxisAlignment.stretch` membuat seluruh kolom input dan tombol **Simpan** sejajar rapi serta mudah dipindai secara visual. Pembatasan `ConstrainedBox(maxWidth: 720)` yang dibungkus `Center` menjaga kolom input tetap proporsional pada layar desktop lebar (tidak membentang terlalu panjang), sekaligus tetap mengisi lebar penuh secara nyaman pada ponsel.
   - **Peran Widget Pengatur Jarak (`Padding`, `SizedBox`) & Widget Penggulir (`SingleChildScrollView`):**
     - **`Padding` & `SizedBox`:** Memberikan ruang napas visual (`EdgeInsets.all(16.0)` di sekeliling form dan `SizedBox(height: 12.0)`/`16.0`/`24.0` antar-kolom dan tombol) agar label error validasi yang muncul di bawah input tidak menempel atau bertumpuk dengan kolom berikutnya.
     - **`SingleChildScrollView`:** Pada layar ponsel sempit atau ketika papan ketik virtual (*on-screen keyboard*) muncul dan menyusutkan tinggi viewport yang tersedia, `Column` tanpa penggulir akan memicu error `RenderFlex overflow` dan menyembunyikan tombol **Simpan**. Dengan membungkus form di dalam `SingleChildScrollView`, seluruh input hingga tombol **Simpan** di bagian paling bawah tetap dapat digulir dan dijangkau kapan saja tanpa error tata letak.

4. **Apa peran `GlobalKey<FormState>`, `validator`, dan `validate()` saat tombol Simpan ditekan? Berikan satu contoh nilai yang ditolak oleh validasi dan jelaskan mengapa memilih jenis input atau papan ketik saja belum cukup.**

   - **Peran Ketiga Komponen Validasi:**
     - **`GlobalKey<FormState>` (`_formKey`):** Bertindak sebagai pengenal unik untuk mengakses objek `FormState` dari widget `Form` di luar metode `build`, tepatnya di dalam handler `_submitForm()` saat tombol **Simpan** ditekan.
     - **`validator`:** Fungsi callback pada tiap field formulir (`TextFormField`, `DropdownButtonFormField`) yang memeriksa nilai terkini; mengembalikan `null` jika valid atau string pesan kesalahan jika tidak valid (yang otomatis dirender berwarna merah di bawah field tersebut).
     - **`_formKey.currentState!.validate()`:** Memanggil fungsi `validator` seluruh field di dalam `Form` secara serentak saat tombol **Simpan** ditekan, memperbarui tampilan pesan error di UI, lalu mengembalikan `true` hanya jika **seluruh** field mengembalikan `null`. Dialog `AlertDialog` hanya dipanggil apabila `validate()` bernilai `true`.
   - **Contoh Nilai yang Ditolak & Mengapa Tipe Input/Keyboard Saja Tidak Cukup:**
     - Contoh nilai yang ditolak oleh validasi pada `ExperienceFormPage`:
       - Input berisi spasi saja (`"   "`) pada **Judul Experience** atau **Deskripsi Experience** (ditolak oleh `value.trim().isEmpty`).
       - Input `"bukan-url-valid"` pada **URL Thumbnail** (ditolak karena tidak memiliki skema `http`/`https` dan host yang valid).
       - Memilih **Tanggal Selesai** yang lebih awal daripada **Tanggal Mulai** (ditolak oleh `_endedAt!.isBefore(_startedAt!)`).
     - Memilih `keyboardType: TextInputType.url`, `maxLength: 255`, atau `readOnly: true` saja **belum cukup** karena sifatnya hanya membantu antarmuka input di sisi klien: pengguna masih dapat mem-paste teks sembarang ke kolom URL, mengetik spasi kosong ke kolom teks wajib, membiarkan tanggal mulai kosong, atau memilih dua tanggal dengan urutan terbalik. Validasi logika di `validator` tetap diperlukan untuk menjamin integritas data sebelum diproses atau ditampilkan.

---

### AI Disclosure (Tugas 8)

Saya menggunakan **Google Antigravity (model Gemini 4 Hydrogen High)** sebagai asisten *pair-programming* dalam pengerjaan Individual Assignment 8.

**Strategi Prompting & Alur Kerja:**
- Memerintahkan AI terlebih dahulu membaca spesifikasi tugas (`individual_assignment_8.md`) sekaligus memeriksa model Django pada repositori web `myportofolio` (`main/models.py`) agar halaman formulir baru di Flutter benar-benar selaras dengan domain model portofolio yang sudah ada (**`Experience`**).
- Menerapkan verifikasi bertahap setelah perubahan kode (`flutter analyze` → `flutter test` → commit kode → pembaruan `README.md` → verifikasi ulang → push ke GitHub).

**Bagian yang Dibantu AI:**
- Implementasi [`lib/screens/experience_form.dart`](lib/screens/experience_form.dart) mengikuti atribut model Django `Experience` (`title`, `category`, `started_at`, `ended_at`, `is_ongoing`, `description`, `thumbnail`) beserta `showDatePicker()`, validasi URL opsional, validasi spasi kosong, dan dialog ringkasan `AlertDialog`.
- Pembaruan [`lib/widgets/left_drawer.dart`](lib/widgets/left_drawer.dart), [`lib/widgets/project_card.dart`](lib/widgets/project_card.dart), [`lib/screens/menu.dart`](lib/screens/menu.dart), serta penyelarasan `Theme.of(context).colorScheme.primary` pada seluruh halaman.
- Penulisan pengujian otomatis di [`test/widget_test.dart`](test/widget_test.dart) untuk menguji seluruh alur navigasi, validasi kasus edge (spasi kosong, URL salah, tanggal terbalik), dialog ringkasan, dan layar sempit 360×800.
- Penyusunan pembaruan dokumentasi dan jawaban reflektif Tugas 8 di `README.md`.

**Keterbatasan AI & Perbaikan Manual yang Dilakukan:**
1. **Perilaku `AppBar` saat `Scaffold.drawer` Aktif pada Pengujian Navigasi Kembali:**
   - Widget test awal mencoba mengetuk `find.byType(BackButton)` setelah `Navigator.push()` ke `ProjectFormPage` dan `ExperienceFormPage`. Namun, pengujian gagal karena `Scaffold` yang memiliki `drawer` secara default menampilkan tombol menu *hamburger* pada posisi `leading` `AppBar` alih-alih `BackButton`.
   - *Perbaikan:* Mengganti simulasi tombol kembali pada `test/widget_test.dart` menjadi `await tester.binding.handlePopRoute()` agar sesuai dengan mekanisme tombol *Back* sistem/browser di Flutter ketika halaman juga menyediakan drawer.
2. **Penanganan Tata Letak 4 Kartu Aksi agar Tetap Simetris di Ponsel & Desktop:**
   - Penambahan kartu ke-4 (`Tambah Experience`) pada kisi 3 kolom sebelumnya berisiko meninggalkan satu kartu sendirian di baris kedua. Penyesuaian dilakukan dengan membungkus `GridView.count` dalam `LayoutBuilder` (2×2 di layar sempit, 4×1 di layar lebar ≥ 560px) dan diverifikasi pada ukuran layar 360×800 tanpa overflow.

---

### Assignment 9

1. **Mengapa kita menggunakan `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` alih-alih mengirim objek `Map<String, dynamic>` mentah langsung dari widget? Jelaskan satu bug yang dicegah atau dapat dicegah oleh pendekatan ini pada model bagianmu.**

   - **Keunggulan Pendekatan Model `@JsonSerializable`:**
     - **Keamanan Tipe (*Type Safety*) & Pemisahan Tanggung Jawab:** Widget cukup bekerja dengan objek Dart bertipe kuat (`Experience`, `Project`) tanpa harus mengingat nama kunci JSON mentah di banyak tempat. Seluruh logika konversi JSON dipusatkan pada `*.g.dart` yang dihasilkan secara deterministik oleh `build_runner`.
     - **Konversi Otomatis `snake_case` ↔ `camelCase` (`FieldRename.snake`):** Konvensi Dart menggunakan `camelCase` (`categoryDisplay`, `endedAt`, `starCount`, `starredByNames`), sedangkan DRF menggunakan `snake_case` (`category_display`, `ended_at`, `star_count`, `starred_by_names`). Anotasi `FieldRename.snake` memetakan keduanya secara otomatis.
     - **Kontrol Ketat Payload Request (`@JsonKey(includeToJson: false)`):** Field *read-only* atau turunan yang ditetapkan server (`id`, `started_at`, `category_display`, `is_ongoing`, `star_count`, `is_starred`, `starred_by_names`) hanya dideserialisasi saat `fromJson()`, tetapi tidak ikut terkirim dalam body `POST` (`toJson()`).
   - **Contoh Bug Nyata yang Dicegah pada Model `Experience`:**
     - Pada `ExperienceSerializer` Django, kolom `thumbnail` didefinisikan sebagai `URLField(blank=True, null=True)` sehingga respons `GET /api/v1/experiences/` dapat bernilai `null`. Jika kita membaca `Map<String, dynamic>` mentah (`json['thumbnail'] as String`) atau lupa memberi nilai default, Flutter akan melempar runtime crash `type 'Null' is not a subtype of type 'String'`. Dengan `@JsonKey(defaultValue: '')` pada model `Experience`, nilai `null` atau kunci yang absen otomatis aman diubah menjadi string kosong `''`. Selain itu, mengecualikan `id` dan `started_at` lewat `@JsonKey(includeToJson: false)` mencegah pengiriman `"id": null` yang tidak dibutuhkan saat membuat entri baru.

2. **Mengapa `Future` yang diteruskan ke `FutureBuilder` harus diinisialisasi di dalam `initState()` alih-alih langsung di dalam `build()`, dan mengapa `ApiClient` sebaiknya melempar `ApiException` daripada mengembalikan `null` pada respons HTTP non-2xx?**

   - **Mengapa `Future` Harus Diinisialisasi di `initState()`:**
     - Metode `build()` dapat dipanggil puluhan kali oleh framework Flutter setiap kali ada perubahan *state*, animasi, kemunculan papan ketik, perubahan tema/`MediaQuery`, atau notifikasi `Provider`. Jika `context.read<ApiClient>().getExperiences()` dipanggil langsung di dalam `build()`, setiap rebuild akan menciptakan instance `Future` baru yang memicu permintaan HTTP GET berulang-ulang ke backend Django tanpa henti serta mereset indikator loading. Dengan menyimpannya dalam `late Future<List<Experience>> _experiencesFuture` di `initState()` (dan hanya memperbaruinya secara eksplisit di dalam `_reload()` saat pengguna melakukan *pull-to-refresh* atau menekan *Retry*), identitas `Future` tetap stabil selama siklus hidup widget.
   - **Mengapa `ApiClient` Sebaiknya Melempar `ApiException` Alih-alih Mengembalikan `null`:**
     - Mengembalikan `null` mengaburkan perbedaan antara "server berhasil menjawab dengan data kosong" dan "permintaan gagal karena error HTTP" (misalnya `401 Unauthorized`, `403 Forbidden`, atau `500 Internal Server Error`). Dengan melempar `ApiException(statusCode, message)`, `FutureBuilder` otomatis menerima kondisi error (`snapshot.hasError == true`) untuk menampilkan tombol **Retry** di `ExperienceListScreen`, serta memungkinkan blok `try / on ApiException` pada `ExperienceFormPage` dan `ExperienceDetailScreen` mendeteksi status `401` secara spesifik untuk membersihkan token usang dan meminta login ulang.

3. **Bandingkan `SessionAuthentication` milik Django (dari Tutorial 04/07) dengan `TokenAuthentication` milik DRF (dari Tutorial 10). Mengapa `myportfolio_mobile` menggunakan `TokenAuthentication` sementara `SessionAuthentication` tetap diaktifkan pada backend Django?**

   - **Perbandingan `SessionAuthentication` vs `TokenAuthentication`:**
     - **`SessionAuthentication`:** Mekanisme *stateful* berbasis cookie `sessionid` di browser yang dipasangkan dengan pemeriksaan token `csrftoken`. Sangat ideal untuk aplikasi web tradisional dan AJAX di browser karena browser otomatis mengelola penyimpanan dan pengiriman cookie di setiap request pada domain yang sama.
     - **`TokenAuthentication`:** Mekanisme *stateless* berbasis tabel `authtoken_token` yang mengirimkan kredensial eksplisit pada header HTTP `Authorization: Token <key>`. Klien mobile tidak bergantung pada *cookie jar* browser maupun alur CSRF token, sehingga bekerja seragam pada Android native, emulator, maupun Flutter Web lintas origin (*CORS*).
   - **Mengapa Keduanya Tetap Aktif di Backend Django:**
     - `myportofolio_mobile` menggunakan `TokenAuthentication` agar request terautentikasi (`POST /api/v1/experiences/`, `DELETE /api/v1/experiences/<id>/`, `POST /api/v1/auth/logout/`) dapat langsung diautentikasi dari memori `AuthState` menggunakan header standar HTTP dan mengembalikan **`401 Unauthorized`** jika token tidak ada atau sudah kedaluwarsa (karena `TokenAuthentication` ditempatkan lebih dulu di `DEFAULT_AUTHENTICATION_CLASSES`). Sementara itu, `SessionAuthentication` tetap dipertahankan di urutan kedua agar halaman web Django (`myportofolio` web templates, AJAX *star* di web, serta DRF Browsable API) tetap berfungsi normal menggunakan session login dan proteksi CSRF di browser.

4. **Jelaskan peran job `build` (`very_good_workflows`) dan `build_apk` dalam pipeline `.github/workflows/main.yaml` milikmu (termasuk pemeriksaan apa saja yang dijalankan `very_good_workflows` di balik layar). Mengapa berkas `*.g.dart` dimasukkan ke `.gitignore` meskipun CI membutuhkannya untuk menganalisis dan membangun aplikasi?**

   - **Peran Job `build` (`VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v2`):**
     - Bertindak sebagai gerbang *Continuous Integration (CI)* yang memverifikasi kualitas seluruh kode sebelum artefak rilis dibangun. Di balik layar, `very_good_workflows` menjalankan tahapan: checkout repo, setup Flutter SDK, instalasi dependensi (`very_good packages get`), langkah `setup` kustom (`dart run build_runner build --delete-conflicting-outputs`), pemeriksaan pemformatan (`dart format --set-exit-if-changed lib test`), analisis statis (`flutter analyze lib test`), resolusi `--dart-define`, serta eksekusi pengujian otomatis (`very_good test`) dengan urutan acak dan laporan cakupan kode (mengecualikan `**/*.g.dart`).
   - **Peran Job `build_apk`:**
     - Bertindak sebagai tahap *Continuous Delivery (CD)* dengan `needs: build`, artinya kompilasi APK hanya berjalan jika seluruh pemeriksaan pada job `build` berhasil. Job ini menyiapkan JDK 17 (`actions/setup-java@v5`), Flutter SDK, menerima lisensi Android SDK, mengunduh paket, men-generate `*.g.dart`, menjalankan `flutter build apk --release` (dengan dukungan opsional `--dart-define=API_BASE_URL=${{ vars.API_BASE_URL }}`), lalu mengunggah `build/app/outputs/flutter-apk/app-release.apk` sebagai artefak `app-release-apk`.
   - **Mengapa `*.g.dart` Tetap Dimasukkan ke `.gitignore`:**
     - Berkas `*.g.dart` adalah kode turunan otomatis (*generated artifact*), bukan sumber tulisan manusia. Menyertakannya di Git memperbesar ukuran commit tanpa nilai tambah review, sering memicu *merge conflict* saat bekerja lintas cabang, dan berisiko usang (*stale*) jika pengembang lupa menjalankan `build_runner` setelah mengubah model. Dengan mengecualikannya di `.gitignore` dan men-generate-nya ulang melalui `build_runner` di dalam langkah `setup` CI, repository tetap bersih sekaligus menjamin kode hasil generasi di CI selalu sinkron dengan definisi model terbaru.

---

### AI Disclosure (Assignment 9)

Saya menggunakan **Google Antigravity (model Gemini 4 Hydrogen High)** sebagai asisten *pair-programming* selama pengerjaan Individual Assignment 9.

**Strategi Prompting & Alur Kerja:**
- Menyelaraskan spesifikasi `individual_assignment_9.md` secara langsung dengan implementasi backend nyata di repositori Django `myportofolio` (`main/models.py`, `main/serializers.py`, `main/api_views.py`, dan `main/permissions.py`) agar setiap field, tipe data, status HTTP, dan izin akses konsisten *end-to-end*.
- Menjalankan verifikasi lokal (`build_runner`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze lib test`, dan `flutter test` berbasis `MockClient`) sebelum *push*, serta memeriksa langsung hasil eksekusi GitHub Actions CI/CD.

**Bagian yang Dibantu AI:**
- Pembuatan model [`lib/models/experience.dart`](lib/models/experience.dart) (`@JsonSerializable`) dan perluasan [`lib/services/api_client.dart`](lib/services/api_client.dart) (`getExperiences`, `createExperience`, serta fitur tambahan `deleteExperience`).
- Pembuatan [`ExperienceListScreen`](lib/screens/experience_list_screen.dart), [`ExperienceDetailScreen`](lib/screens/experience_detail_screen.dart), serta refactor [`ExperienceFormPage`](lib/screens/experience_form.dart), [`LeftDrawer`](lib/widgets/left_drawer.dart), [`ItemCard`](lib/widgets/project_card.dart), dan [`MyHomePage`](lib/screens/menu.dart).
- Penulisan pengujian otomatis menggunakan `MockClient` di [`test/widget_test.dart`](test/widget_test.dart) untuk memverifikasi GET publik, empty/error/retry state, detail screen, `ensureLoggedIn`, POST & DELETE terautentikasi, penanganan `401`, serialisasi JSON, serta tata letak responsif 360×800.
- Pembaruan `README.md` (badge CI, instruksi setup `build_runner` & `API_BASE_URL`, jawaban reflektif, dan AI disclosure).

**Keterbatasan AI & Perbaikan Manual / Iterasi yang Dilakukan:**
1. **Ketidaksinkronan Kunci Pilihan Kategori antara Form Assignment 8 dan Serializer Django:**
   - Pada Assignment 8 sebelumnya, dropdown kategori menyimpan nilai label kapital seperti `'Full-Time'` dan `'Internship'`. Saat memeriksa `ExperienceSerializer.validate_category` di Django, ternyata backend hanya menerima kunci huruf kecil (`'full-time'`, `'internship'`, `'research'`, `'volunteer'`, `'part-time'`, `'freelance'`) dan akan menolak `'Full-Time'` dengan status `400`.
   - *Perbaikan:* Mengubah struktur kategori pada `ExperienceFormPage` menjadi `Map<String, String>` yang menampilkan label terbaca manusia di UI tetapi mengirimkan kunci *lowercase* yang valid ke API DRF, serta mengonfigurasi `@JsonKey(defaultValue: '')` untuk `thumbnail` yang dapat bernilai `null`.
2. **Penanganan Field `read_only` (`started_at`) & Kompatibilitas CI Flutter 3.50.1:**
   - Memastikan `@JsonKey(includeToJson: false)` diterapkan pada `id`, `startedAt`, `categoryDisplay`, `isOngoing`, `starCount`, `isStarred`, dan `starredByNames` agar payload `POST` bersih sesuai `ExperienceSerializer.Meta.read_only_fields`, serta mempertahankan kompatibilitas `material_ui`, JDK 17, AGP `9.1.1`, dan Gradle `9.5.0` agar workflow CI/CD tetap hijau penuh.
