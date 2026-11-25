import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan data pengalaman (Experience) baru ke dalam portofolio.
/// Field dan aturan validasi disesuaikan dengan model `Experience` pada backend Django.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  static const String _defaultCategory = 'Full-Time';
  static const List<String> _categories = [
    'Internship',
    'Research',
    'Volunteer',
    'Part-Time',
    'Full-Time',
    'Freelance',
  ];

  String _category = _defaultCategory;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Memformat [DateTime] menjadi string tanggal `YYYY-MM-DD`.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Membuka pemilih tanggal (`showDatePicker`) untuk tanggal mulai atau tanggal selesai.
  Future<void> _pickDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startedAt ?? DateTime.now())
        : (_endedAt ?? _startedAt ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        _startedAt = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endedAt = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  /// Memvalidasi format URL opsional (hanya mengizinkan skema `http` atau `https`).
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

  /// Mengatur ulang seluruh state dan controller formulir setelah dialog ditutup.
  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _category = _defaultCategory;
      _startedAt = null;
      _endedAt = null;
      _isOngoing = false;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final thumbnail = _thumbnailController.text.trim();
    final startDateText = _formatDate(_startedAt!);
    final endDateText = (_isOngoing || _endedAt == null)
        ? 'Masih berlangsung'
        : _formatDate(_endedAt!);

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
                Text('Judul: $title'),
                const SizedBox(height: 4),
                Text('Kategori: $_category'),
                const SizedBox(height: 4),
                Text('Tanggal Mulai: $startDateText'),
                const SizedBox(height: 4),
                Text('Tanggal Selesai: $endDateText'),
                const SizedBox(height: 4),
                Text('Deskripsi: $description'),
                const SizedBox(height: 4),
                Text('Thumbnail: ${thumbnail.isEmpty ? '-' : thumbnail}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
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
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
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
                    const SizedBox(height: 16.0),

                    // === Tanggal Mulai ===
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: _fieldDecoration(
                        labelText: 'Tanggal Mulai',
                        hintText: 'Pilih tanggal mulai (YYYY-MM-DD)',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDate(isStartDate: true),
                      validator: (String? value) {
                        if (_startedAt == null ||
                            (value?.trim().isEmpty ?? true)) {
                          return 'Tanggal mulai tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),

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
                      onTap: _isOngoing
                          ? null
                          : () => _pickDate(isStartDate: false),
                      validator: (String? value) {
                        if (_isOngoing || _endedAt == null) {
                          return null;
                        }
                        if (_startedAt != null &&
                            _endedAt!.isBefore(_startedAt!)) {
                          return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
                        }
                        return null;
                      },
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

                    // === Tombol Simpan ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'Simpan',
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
