import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Model data untuk setiap item tombol menu aksi pada beranda portofolio,
/// menyimpan label ([name]), ikon ([icon]), dan warna latar unik ([color]).
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}

/// Widget kartu tombol aksi portofolio yang dapat ditekan.
/// Menggunakan warna latar unik dari [item], memunculkan [SnackBar],
/// serta melakukan navigasi ke [ProjectFormPage] atau [ExperienceFormPage].
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

          // Navigasi ke halaman form sesuai kartu aksi yang ditekan
          final Widget? destination = switch (item.name) {
            "Tambah Proyek" => const ProjectFormPage(),
            "Tambah Experience" => const ExperienceFormPage(),
            _ => null,
          };

          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
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
