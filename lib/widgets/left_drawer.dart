import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Widget drawer menu samping untuk navigasi aplikasi MyPortfolio.
/// Menyediakan akses ke Beranda, Daftar Proyek, Daftar Experience,
/// Form Proyek/Experience (terlindungi login), serta Login/Logout berbasis token DRF.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

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

  Widget _buildGuardedNavTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        final allowed = await ensureLoggedIn(context);
        if (!allowed || !context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
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
                    style: TextStyle(fontSize: 15, color: Colors.white),
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
            icon: Icons.folder_outlined,
            title: 'Projects',
            destination: const ProjectListScreen(),
          ),
          _buildGuardedNavTile(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'Add Project',
            destination: const ProjectFormPage(),
          ),
          _buildNavTile(
            context: context,
            icon: Icons.work_history_outlined,
            title: 'Experiences',
            destination: const ExperienceListScreen(),
          ),
          _buildGuardedNavTile(
            context: context,
            icon: Icons.work_outline,
            title: 'Add Experience',
            destination: const ExperienceFormPage(),
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                await navigator.push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final authState = context.read<AuthState>();
                Navigator.pop(context);
                await authState.logout();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Berhasil logout.')),
                  );
              },
            ),
        ],
      ),
    );
  }
}
