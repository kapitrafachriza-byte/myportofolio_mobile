import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan [Project] baru dan mengirimkannya ke backend Django DRF.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _projectImageUrlController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _projectImageUrlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value, {required bool required}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required ? 'Project URL cannot be empty!' : null;
    }
    final uri = Uri.tryParse(trimmed);
    final validScheme =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    final validHost =
        uri != null && (uri.host.contains('.') || uri.host == 'localhost');
    if (!validScheme || !validHost) {
      return 'Invalid URL! Use http:// or https://';
    }
    return null;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _techStackController.clear();
    _projectUrlController.clear();
    _projectImageUrlController.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final newProject = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      techStack: _techStackController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      projectImageUrl: _projectImageUrlController.text.trim(),
    );

    try {
      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Proyek berhasil ditambahkan!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Title: ${created.title}'),
                  Text('Description: ${created.description}'),
                  Text('Tech Stack: ${created.techStack}'),
                  Text('Project URL: ${created.projectUrl}'),
                  Text(
                    'Image URL: ${created.projectImageUrl.isEmpty ? '-' : created.projectImageUrl}',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
            ),
          );
        await ensureLoggedIn(context);
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to save project (${e.statusCode}).')),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Network error while saving project.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: _decoration('Title', 'Project Title'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title cannot be empty!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: _decoration(
                      'Description',
                      'Project Description',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description cannot be empty!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _techStackController,
                    decoration: _decoration(
                      'Tech Stack',
                      'Contoh: Flutter, Django, PostgreSQL',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tech Stack cannot be empty!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _projectUrlController,
                    keyboardType: TextInputType.url,
                    decoration: _decoration(
                      'Project URL',
                      'https://github.com/username/project',
                    ),
                    validator: (value) => _validateUrl(value, required: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _projectImageUrlController,
                    keyboardType: TextInputType.url,
                    decoration: _decoration(
                      'Project Image URL (Optional)',
                      'https://example.com/preview.png',
                    ),
                    validator: (value) => _validateUrl(value, required: false),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
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
