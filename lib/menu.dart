import 'package:flutter/material.dart';

/// Halaman utama aplikasi portofolio mobile (StatelessWidget).
/// Menampilkan kartu informasi pemilik portofolio serta grid menu aksi
/// portofolio dengan warna kartu yang berbeda-beda.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506623231";
  final String nama = "Kapitra Fachriza Utomo";
  final String kelas = "PBP E";

  final List<ItemHomepage> items = const [
    ItemHomepage("Lihat Experience", Icons.work_outline, Color(0xFF1565C0)),
    ItemHomepage("Tambah Experience", Icons.add_circle_outline, Color(0xFF2E7D32)),
    ItemHomepage("Logout", Icons.logout, Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // Body halaman utama dengan dukungan scroll dan lebar maksimal responsif.
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Baris horizontal dengan tinggi seragam untuk menampilkan 3 InfoCard sejajar.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: InfoCard(title: 'NPM', content: npm)),
                        const SizedBox(width: 8.0),
                        Expanded(child: InfoCard(title: 'Name', content: nama)),
                        const SizedBox(width: 8.0),
                        Expanded(child: InfoCard(title: 'Class', content: kelas)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
                  Center(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Selamat datang di MyPortfolio Mobile!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                        GridView.count(
                          primary: false,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                          shrinkWrap: true,
                          children: items.map((ItemHomepage item) {
                            return ItemCard(item);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu informasi untuk menampilkan judul ([title]) dan isi ([content])
/// profil pemilik portofolio dengan tata letak terpusat.
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
        // Menyusun teks title dan content secara vertikal dan simetris.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Model data untuk setiap item tombol menu aksi pada beranda portofolio,
/// menyimpan label ([name]), ikon ([icon]), dan warna latar unik ([color]).
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}

/// Widget kartu tombol aksi portofolio yang dapat ditekan.
/// Menggunakan warna latar unik dari [item] dan memunculkan [SnackBar] saat ditekan.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna unik dari atribut item.color (modular tanpa percabangan).
      color: item.color,
      elevation: 3.0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Menampilkan SnackBar interaktif sesuai nama tombol yang ditekan.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 28.0,
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
