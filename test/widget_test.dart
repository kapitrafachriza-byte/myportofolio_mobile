import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets(
    'MyPortfolio renders owner InfoCards, distinct colored ItemCards, and interactive SnackBars',
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

      // Verifikasi ketiga tombol menu tampil dan memakai warna latar berbeda
      const expectedButtons = [
        'Lihat Proyek',
        'Tambah Proyek',
        'Logout',
      ];
      for (final label in expectedButtons) {
        expect(find.text(label), findsOneWidget);
      }

      final itemCardWidgets =
          tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
      expect(itemCardWidgets.length, 3);

      final cardColors = <Color?>{};
      for (final itemCard in itemCardWidgets) {
        final materialFinder = find.descendant(
          of: find.byWidget(itemCard),
          matching: find.byType(Material),
        );
        final materialWidget = tester.widget<Material>(materialFinder.first);
        cardColors.add(materialWidget.color);
      }
      expect(cardColors.length, 3);

      // Verifikasi interaksi ketuk tombol memunculkan SnackBar
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
    'Navigation via LeftDrawer navigates between MyHomePage and ProjectFormPage',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Buka drawer dengan menekan ikon hamburger pada AppBar
      final drawerIcon = find.byTooltip('Open navigation menu');
      expect(drawerIcon, findsOneWidget);
      await tester.tap(drawerIcon);
      await tester.pumpAndSettle();

      // Verifikasi komponen DrawerHeader
      expect(find.byType(LeftDrawer), findsOneWidget);
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );

      // Verifikasi ListTile menu drawer
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);

      // Navigasi ke ProjectFormPage via drawer
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);

      // Buka drawer kembali di ProjectFormPage dan kembali ke Home
      final drawerIconOnForm = find.byTooltip('Open navigation menu');
      await tester.tap(drawerIconOnForm);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'Navigation via ItemCard Tambah Proyek pushes ProjectFormPage and back button pops',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Ketuk kartu Tambah Proyek pada halaman beranda
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      // Pastikan berpindah ke halaman ProjectFormPage
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);

      // Tekan tombol navigasi Back (pop)
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
      }
    },
  );

  testWidgets(
    'ProjectFormPage validates inputs and displays AlertDialog on valid submission',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ProjectFormPage(),
      ));

      // 1. Coba simpan form yang masih kosong
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      // Verifikasi pesan error validasi muncul
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

      // 2. Isi data formulir yang valid
      final textFields = find.byType(TextFormField);
      // Field 0: Nama Proyek
      await tester.enterText(textFields.at(0), 'Website Portofolio');
      // Field 1: Deskripsi Proyek
      await tester.enterText(
        textFields.at(1),
        'Aplikasi portofolio pribadi multiplatform.',
      );
      // Field 2: Teknologi yang Digunakan
      await tester.enterText(textFields.at(2), 'Flutter, Dart, Django');
      // Field 3: Tautan Proyek
      await tester.enterText(
        textFields.at(3),
        'https://github.com/kapitrafachriza-byte',
      );
      await tester.pump();

      // Tekan tombol Save kembali
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verifikasi dialog pop-up konfirmasi muncul
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Website Portofolio'), findsOneWidget);
      expect(
        find.text('Deskripsi: Aplikasi portofolio pribadi multiplatform.'),
        findsOneWidget,
      );
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Dart, Django'), findsOneWidget);
      expect(
        find.text('Tautan: https://github.com/kapitrafachriza-byte'),
        findsOneWidget,
      );

      // Tekan tombol OK untuk menutup dialog dan mereset form
      final okButton = find.widgetWithText(TextButton, 'OK');
      expect(okButton, findsOneWidget);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'MyPortfolio renders cleanly without overflow on narrow mobile viewport',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());

      expect(tester.takeException(), isNull);
      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.byType(ItemCard), findsNWidgets(3));
    },
  );
}
