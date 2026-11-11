# MyPortfolio Mobile (`myportofolio_mobile`)

Aplikasi mobile multiplatform berbasis **Flutter** untuk portofolio pribadi **Kapitra Fachriza Utomo**, dibangun sebagai klien mobile pendamping dari website portofolio web Django ([`myportofolio`](https://github.com/kapitrafachriza-byte/myportofolio)).

- **Nama:** Kapitra Fachriza Utomo
- **NPM:** `2506623231`
- **Kelas:** PBP E
- **Repositori Mobile:** https://github.com/kapitrafachriza-byte/myportofolio_mobile
- **Repositori Web (Django & DRF):** https://github.com/kapitrafachriza-byte/myportofolio

---

## Fitur & Struktur Saat Ini

1. **Halaman Beranda Modular (`lib/menu.dart`)**:
   - Dipisahkan dari entry point utama (`lib/main.dart`) menggunakan pendekatan `StatelessWidget`.
   - **Kartu Identitas Pemilik (`InfoCard`)**: Menampilkan NPM, Nama Lengkap, dan Kelas dengan tinggi dan lebar kartu yang simetris (`IntrinsicHeight` + `Expanded`).
   - **Kisi Menu Aksi Portofolio (`ItemCard`)**: Menampilkan tombol interaktif sesuai modul portofolio pribadi (*Lihat Experience*, *Tambah Experience*, dan *Logout*) dengan warna latar berbeda yang kontras dan dikelola secara modular lewat properti `color` pada model `ItemHomepage`.
   - **Umpan Balik Interaktif (`SnackBar`)**: Menampilkan notifikasi melayang bertuliskan `"Kamu telah menekan tombol [Nama Tombol]!"` saat kartu ditekan.
   - **Tata Letak Responsif**: Menggunakan `SingleChildScrollView` + `ConstrainedBox(maxWidth: 720)` dan `childAspectRatio` yang proporsional agar bebas dari *overflow* pada layar ponsel sempit (360px) maupun tetap rapi di peramban desktop.

### Struktur Berkas Utama

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart        # Entry point aplikasi, konfigurasi MaterialApp & tema Material 3
│   └── menu.dart        # Halaman beranda MyHomePage, InfoCard, ItemHomepage, & ItemCard
├── test/
│   └── widget_test.dart # Pengujian widget (InfoCard, warna unik ItemCard, SnackBar, & viewport 360px)
├── analysis_options.yaml
└── pubspec.yaml
```

---

## Setup & Menjalankan Proyek

### Prasyarat
- **Flutter SDK** (diuji pada versi `3.47.9`, Dart `3.13.7`) terdaftar pada `PATH`.
- **Google Chrome** (untuk menjalankan target web) atau **Android Studio & Android SDK** (untuk emulator/perangkat Android).

### Langkah Menjalankan Lokal

```powershell
# 1. Clone repositori
git clone https://github.com/kapitrafachriza-byte/myportofolio_mobile.git
cd myportofolio_mobile

# 2. Unduh dependensi Dart/Flutter
flutter pub get

# 3. Verifikasi toolchain
flutter doctor

# 4. Jalankan aplikasi di Google Chrome
flutter run -d chrome
```

### Analisis Kode & Unit Testing

```powershell
# Memeriksa linter & aturan sintaks Dart
flutter analyze

# Menjalankan widget tests
flutter test
```

---

## Progres Mingguan

- **Tutorial 08 (Basic Flutter):** Instalasi Flutter SDK, verifikasi `flutter doctor`, inisialisasi proyek `myportofolio_mobile`, pemisahan `menu.dart` dari `main.dart`, penerapan tema Material 3 (`ColorScheme.fromSeed`), komponen dasar `InfoCard`, `ItemHomepage`, `ItemCard`, serta interaksi `SnackBar`.
- **Individual Assignment 7 (Basic Flutter):** Kustomisasi penuh identitas pribadi di `InfoCard`, penyesuaian menu aksi portofolio berbasis modul *Experience* dengan warna latar unik per kartu tanpa percabangan berulang, peningkatan simetri dan responsivitas layout (`IntrinsicHeight`, `Expanded`, `ConstrainedBox`), penambahan Dart doc comments, pembaruan widget test termasuk uji layar sempit 360px, serta dokumentasi & jawaban reflektif di `README.md`.

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
