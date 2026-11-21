import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Widget drawer menu samping untuk navigasi aplikasi MyPortfolio.
/// Menyediakan akses ke Halaman Utama, Form Tambah Proyek, dan Form Tambah Experience.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Helper untuk membangun item navigasi drawer dengan pola [Navigator.pushReplacement].
  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNavTile(
            context: context,
            icon: Icons.home_outlined,
            title: 'Home',
            destination: const MyHomePage(),
          ),
          _buildNavTile(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'Add Project',
            destination: const ProjectFormPage(),
          ),
          _buildNavTile(
            context: context,
            icon: Icons.work_outline,
            title: 'Add Experience',
            destination: const ExperienceFormPage(),
          ),
        ],
      ),
    );
  }
}
