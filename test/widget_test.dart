import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

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
        'Lihat Experience',
        'Tambah Experience',
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

      // Verifikasi interaksi ketuk setiap tombol memunculkan SnackBar yang sesuai
      for (final label in expectedButtons) {
        await tester.tap(find.text(label));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Kamu telah menekan tombol $label!'), findsOneWidget);
      }
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
