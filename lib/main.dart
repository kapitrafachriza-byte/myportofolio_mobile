import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget aplikasi mobile MyPortfolio.
/// Mengonfigurasi tema Material 3, judul aplikasi, serta halaman beranda awal.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
