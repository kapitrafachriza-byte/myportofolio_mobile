import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan data [Experience] baru ke backend Django DRF.
/// Membutuhkan autentikasi token sebelum melakukan POST ke `/api/v1/experiences/`.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({this.openedFromList = false, super.key});

  final bool openedFromList;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _endDateController = TextEditingController();

  static const String _defaultCategory = 'full-time';
  static const Map<String, String> _categoryChoices = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  String _category = _defaultCategory;
  DateTime? _endedAt;
  bool _isOngoing = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _endedAt = picked;
      _endDateController.text = _formatDate(picked);
    });
  }

  String? _validateOptionalUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    final hasValidScheme =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    final hasValidHost =
        uri != null && (uri.host.contains('.') || uri.host == 'localhost');

    if (!hasValidScheme || !hasValidHost) {
      return 'Format URL tidak valid! Gunakan awalan http:// atau https://';
    }
    return null;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _endDateController.clear();
    setState(() {
      _category = _defaultCategory;
      _endedAt = null;
      _isOngoing = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final newExperience = Experience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      thumbnail: _thumbnailController.text.trim(),
      endedAt: _isOngoing ? null : _endedAt,
    );

    try {
      final created = await context.read<ApiClient>().createExperience(
        newExperience,
        token: token,
      );
      if (!mounted) return;

      final categoryLabel = created.categoryDisplay.isNotEmpty
          ? created.categoryDisplay
          : (_categoryChoices[created.category] ?? created.category);
      final endDateText = (created.isOngoing || created.endedAt == null)
          ? 'Masih berlangsung'
          : _formatDate(created.endedAt!);

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Experience berhasil ditambahkan!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Judul: ${created.title}'),
                  const SizedBox(height: 4),
                  Text('Kategori: $categoryLabel'),
                  const SizedBox(height: 4),
                  Text('Tanggal Selesai: $endDateText'),
                  const SizedBox(height: 4),
                  Text('Deskripsi: ${created.description}'),
                  const SizedBox(height: 4),
                  Text(
                    'Thumbnail: ${created.thumbnail.isEmpty ? '-' : created.thumbnail}',
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
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (widget.openedFromList) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExperienceListScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Lihat Daftar'),
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
          SnackBar(
            content: Text('Failed to save experience (${e.statusCode}).'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Network error while saving experience.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Tambah Experience',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === Judul Experience ===
                    TextFormField(
                      controller: _titleController,
                      maxLength: 255,
                      decoration: _fieldDecoration(
                        labelText: 'Judul Experience',
                        hintText: 'Contoh: Software Engineer Intern',
                      ),
                      validator: (String? value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Judul experience tidak boleh kosong!';
                        }
                        if (trimmed.length > 255) {
                          return 'Judul experience maksimal 255 karakter!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // === Kategori Experience ===
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _fieldDecoration(
                        labelText: 'Kategori Experience',
                        hintText: 'Pilih kategori',
                      ),
                      items: _categoryChoices.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          _category = newValue;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori harus dipilih!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // === Status Masih Berlangsung ===
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih berlangsung (Ongoing)'),
                      value: _isOngoing,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? checked) {
                        setState(() {
                          _isOngoing = checked ?? false;
                          if (_isOngoing) {
                            _endedAt = null;
                            _endDateController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8.0),

                    // === Tanggal Selesai ===
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      enabled: !_isOngoing,
                      decoration: _fieldDecoration(
                        labelText: 'Tanggal Selesai (Opsional)',
                        hintText: _isOngoing
                            ? 'Masih berlangsung'
                            : 'Pilih tanggal selesai (YYYY-MM-DD)',
                        suffixIcon: _endedAt != null && !_isOngoing
                            ? IconButton(
                                tooltip: 'Hapus tanggal selesai',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _endedAt = null;
                                    _endDateController.clear();
                                  });
                                },
                              )
                            : const Icon(Icons.calendar_today),
                      ),
                      onTap: _isOngoing ? null : _pickEndDate,
                    ),
                    const SizedBox(height: 16.0),

                    // === Deskripsi Experience ===
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _fieldDecoration(
                        labelText: 'Deskripsi Experience',
                        hintText:
                            'Jelaskan peran, tanggung jawab, dan pencapaian',
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi experience tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // === URL Thumbnail ===
                    TextFormField(
                      controller: _thumbnailController,
                      keyboardType: TextInputType.url,
                      decoration: _fieldDecoration(
                        labelText: 'URL Thumbnail (Opsional)',
                        hintText: 'https://example.com/thumbnail.png',
                      ),
                      validator: _validateOptionalUrl,
                    ),
                    const SizedBox(height: 24.0),

                    // === Tombol Save ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
