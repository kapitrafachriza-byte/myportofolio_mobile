import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

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
/// serta melakukan navigasi atau autentikasi sesuai tombol yang dipilih.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  Future<void> _handleTap(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (item.name == 'Logout') {
      final authState = context.read<AuthState>();
      if (authState.isLoggedIn) {
        await authState.logout();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Berhasil logout.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Kamu telah menekan tombol ${item.name}!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Kamu telah menekan tombol ${item.name}!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

    if (item.name == 'Lihat Proyek') {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const ProjectListScreen()),
      );
    } else if (item.name == 'Tambah Proyek') {
      final allowed = await ensureLoggedIn(context);
      if (!allowed || !context.mounted) return;
      await navigator.push(
        MaterialPageRoute(builder: (_) => const ProjectFormPage()),
      );
    } else if (item.name == 'Lihat Experience') {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const ExperienceListScreen()),
      );
    } else if (item.name == 'Tambah Experience') {
      final allowed = await ensureLoggedIn(context);
      if (!allowed || !context.mounted) return;
      await navigator.push(
        MaterialPageRoute(builder: (_) => const ExperienceFormPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      elevation: 3.0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 28.0),
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
