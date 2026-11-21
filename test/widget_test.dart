import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets(
    'MyPortfolio renders owner InfoCards, 4 distinct colored ItemCards, and interactive SnackBars',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verifikasi judul AppBar dan 3 InfoCard identitas pemilik
      expect(find.text('MyPortfolio'), findsOneWidget);
      expect(find.text('NPM'), findsOneWidget);
      expect(find.text('2506623231'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Kapitra Fachriza Utomo'), findsOneWidget);
      expect(find.text('Class'), findsOneWidget);
      expect(find.text('PBP E'), findsOneWidget);

      expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);

      // Verifikasi ketiga InfoCard memiliki tinggi yang seragam
      final infoCardFinders = find.byType(InfoCard);
      expect(infoCardFinders, findsNWidgets(3));
      final infoCardHeights = tester
          .widgetList<InfoCard>(infoCardFinders)
          .map((card) => tester.getSize(find.byWidget(card)).height)
          .toSet();
      expect(infoCardHeights.length, 1);

      // Verifikasi keempat tombol menu tampil dan memakai warna latar berbeda
      const expectedButtons = [
        'Lihat Proyek',
        'Tambah Proyek',
        'Tambah Experience',
        'Logout',
      ];
      for (final label in expectedButtons) {
        expect(find.text(label), findsOneWidget);
      }

      final itemCardWidgets =
          tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
      expect(itemCardWidgets.length, 4);

      final cardColors = <Color?>{};
      for (final itemCard in itemCardWidgets) {
        final materialFinder = find.descendant(
          of: find.byWidget(itemCard),
          matching: find.byType(Material),
        );
        final materialWidget = tester.widget<Material>(materialFinder.first);
        cardColors.add(materialWidget.color);
      }
      expect(cardColors.length, 4);

      // Verifikasi interaksi ketuk tombol non-navigasi memunculkan SnackBar
      await tester.tap(find.text('Lihat Proyek'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsOneWidget);

      await tester.tap(find.text('Logout'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    },
  );

  testWidgets(
    'Navigation via LeftDrawer includes Home, Add Project, and Add Experience',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Buka drawer dari MyHomePage
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      // Verifikasi header & semua opsi drawer
      expect(find.byType(LeftDrawer), findsOneWidget);
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);

      // Navigasi ke ProjectFormPage via drawer
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);

      // Buka drawer di ProjectFormPage dan pindah ke ExperienceFormPage
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Form Tambah Experience'), findsOneWidget);

      // Buka drawer di ExperienceFormPage dan kembali ke Home
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'Navigation via ItemCard pushes ProjectFormPage and ExperienceFormPage and supports system Back',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // 1. Navigasi ke ProjectFormPage
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // Simulasi tombol Back perangkat/browser (Navigator.pop)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);

      // 2. Navigasi ke ExperienceFormPage
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Form Tambah Experience'), findsOneWidget);

      // Simulasi tombol Back perangkat/browser (Navigator.pop)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'ExperienceFormPage rejects empty/whitespace/invalid URL/reversed dates and renders summary AlertDialog on valid submit',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ExperienceFormPage(),
      ));

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      expect(saveButton, findsOneWidget);

      // 1. Uji submit kosong
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget,
      );

      // 2. Uji spasi saja & format URL salah
      final textFields = find.byType(TextFormField);
      // 0: Judul, 1: Tanggal Mulai, 2: Tanggal Selesai, 3: Deskripsi, 4: Thumbnail
      await tester.enterText(textFields.at(0), '   ');
      await tester.enterText(textFields.at(3), '   ');
      await tester.enterText(textFields.at(4), 'bukan-url-valid');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget,
      );
      expect(
        find.text('Format URL tidak valid! Gunakan awalan http:// atau https://'),
        findsOneWidget,
      );

      // 3. Isi data valid + pilih tanggal mulai & tanggal selesai lebih awal untuk menguji urutan tanggal
      await tester.enterText(textFields.at(0), 'Software Engineering Intern');
      await tester.enterText(
        textFields.at(3),
        'Membangun fitur REST API Django dan UI Flutter.',
      );
      await tester.enterText(
        textFields.at(4),
        'https://example.com/internship.png',
      );

      // Pilih Tanggal Mulai: tanggal 15 bulan berjalan
      await tester.ensureVisible(textFields.at(1));
      await tester.tap(textFields.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Pilih Tanggal Selesai lebih awal: tanggal 10 bulan berjalan
      await tester.ensureVisible(textFields.at(2));
      await tester.tap(textFields.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
        findsOneWidget,
      );

      // 4. Perbaiki Tanggal Selesai menjadi tanggal 20 (valid) & submit
      await tester.ensureVisible(textFields.at(2));
      await tester.tap(textFields.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Ubah kategori ke Internship
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verifikasi AlertDialog muncul dengan seluruh ringkasan isian
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Judul: Software Engineering Intern'), findsOneWidget);
      expect(find.text('Kategori: Internship'), findsOneWidget);
      expect(
        find.text('Deskripsi: Membangun fitur REST API Django dan UI Flutter.'),
        findsOneWidget,
      );
      expect(
        find.text('Thumbnail: https://example.com/internship.png'),
        findsOneWidget,
      );

      // Tutup dialog
      await tester.tap(find.widgetWithText(TextButton, 'Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'ProjectFormPage validates inputs and displays AlertDialog on valid submission',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProjectFormPage(),
      ));

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Website Portofolio');
      await tester.enterText(
        textFields.at(1),
        'Aplikasi portofolio pribadi multiplatform.',
      );
      await tester.enterText(textFields.at(2), 'Flutter, Dart, Django');
      await tester.enterText(
        textFields.at(3),
        'https://github.com/kapitrafachriza-byte',
      );
      await tester.pump();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Website Portofolio'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'MyHomePage and ExperienceFormPage render cleanly without overflow on narrow mobile viewport (360x800)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Cek beranda pada layar 360x800
      await tester.pumpWidget(const MyApp());
      expect(tester.takeException(), isNull);
      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.byType(ItemCard), findsNWidgets(4));

      // Navigasi ke ExperienceFormPage pada layar sempit dan gulir ke tombol Simpan
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      expect(saveButton, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
