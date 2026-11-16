import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Halaman utama aplikasi portofolio mobile (StatelessWidget).
/// Menampilkan kartu informasi pemilik portofolio, menu drawer navigasi,
/// serta grid menu aksi portofolio dengan warna kartu yang berbeda-beda.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506623231";
  final String nama = "Kapitra Fachriza Utomo";
  final String kelas = "PBP E";

  final List<ItemHomepage> items = const [
    ItemHomepage("Lihat Proyek", Icons.folder, Color(0xFF1565C0)),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Color(0xFF2E7D32)),
    ItemHomepage("Logout", Icons.logout, Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Drawer, Body, SnackBar).
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer menu navigasi samping
      drawer: const LeftDrawer(),
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
