import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

ApiClient _createMockApiClient({
  List<Map<String, dynamic>>? projectsPayload,
  int projectsStatusCode = 200,
  String? expectedAuthHeader,
  void Function(Map<String, dynamic> body, Map<String, String> headers)?
  onCreateProject,
}) {
  final sampleProjects =
      projectsPayload ??
      [
        {
          'id': '11111111-1111-1111-1111-111111111111',
          'title': 'Portfolio Web',
          'description': 'Personal website built with Django and DRF.',
          'tech_stack': 'Django, Python, Tailwind',
          'project_url': 'https://example.com/portfolio',
          'project_image_url': '',
        },
        {
          'id': '22222222-2222-2222-2222-222222222222',
          'title': 'Flutter Companion',
          'description': 'Mobile client synchronized with REST API.',
          'tech_stack': 'Flutter, Dart',
          'project_url': 'https://example.com/mobile',
          'project_image_url': '',
        },
      ];

  final mockHttp = MockClient((request) async {
    if (request.url.path == '/api/v1/projects/' && request.method == 'GET') {
      return http.Response(
        jsonEncode(sampleProjects),
        projectsStatusCode,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path == '/api/v1/projects/' && request.method == 'POST') {
      if (expectedAuthHeader != null &&
          request.headers['Authorization'] != expectedAuthHeader) {
        return http.Response('{"detail": "Unauthorized"}', 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      onCreateProject?.call(body, request.headers);
      return http.Response(
        jsonEncode({'id': '33333333-3333-3333-3333-333333333333', ...body}),
        201,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path == '/api/v1/auth/token/' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        return http.Response(
          jsonEncode({'token': 'test-token-123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        '{"non_field_errors": ["Invalid credentials"]}',
        400,
      );
    }
    if (request.url.path == '/api/v1/auth/logout/' &&
        request.method == 'POST') {
      return http.Response('', 204);
    }
    return http.Response('Not found', 404);
  });

  return ApiClient(client: mockHttp, baseUrl: 'http://localhost:8000');
}

void main() {
  testWidgets(
    'MyPortfolio renders owner InfoCards, 4 distinct colored ItemCards, and Logout SnackBar',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      expect(find.text('MyPortfolio'), findsOneWidget);
      expect(find.text('NPM'), findsOneWidget);
      expect(find.text('2506623231'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Kapitra Fachriza Utomo'), findsOneWidget);
      expect(find.text('Class'), findsOneWidget);
      expect(find.text('PBP E'), findsOneWidget);

      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );

      final infoCardFinders = find.byType(InfoCard);
      expect(infoCardFinders, findsNWidgets(3));
      final infoCardHeights = tester
          .widgetList<InfoCard>(infoCardFinders)
          .map((card) => tester.getSize(find.byWidget(card)).height)
          .toSet();
      expect(infoCardHeights.length, 1);

      const expectedButtons = [
        'Lihat Proyek',
        'Tambah Proyek',
        'Tambah Experience',
        'Logout',
      ];
      for (final label in expectedButtons) {
        expect(find.text(label), findsOneWidget);
      }

      final itemCardWidgets = tester
          .widgetList<ItemCard>(find.byType(ItemCard))
          .toList();
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

      await tester.tap(find.text('Logout'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    },
  );

  testWidgets(
    'Public ProjectListScreen fetches projects and navigates to ProjectDetailScreen without login',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(find.text('Portfolio Web'), findsOneWidget);
      expect(find.text('Flutter Companion'), findsOneWidget);

      await tester.tap(find.text('Portfolio Web'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('Tech Stack: Django, Python, Tailwind'), findsOneWidget);
      expect(
        find.text('Personal website built with Django and DRF.'),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets(
    'ProjectListScreen shows empty state when API returns no projects',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(projectsPayload: const [])),
      );

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.text('No projects found.'), findsOneWidget);
    },
  );

  testWidgets(
    'Auth guard redirects unauthenticated Add Project to LoginScreen, then allows drawer Logout',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      // Buka drawer -> verifikasi Login tampil, lalu pilih Add Project -> diarahkan ke LoginScreen
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final drawerFinder = find.byType(LeftDrawer);
      expect(drawerFinder, findsOneWidget);
      expect(
        find.descendant(of: drawerFinder, matching: find.text('Login')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: drawerFinder, matching: find.text('Logout')),
        findsNothing,
      );
      expect(
        find.descendant(of: drawerFinder, matching: find.text('Projects')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: drawerFinder, matching: find.text('Add Project')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: drawerFinder,
          matching: find.text('Add Experience'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: drawerFinder, matching: find.text('Add Project')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Uji validasi kosong di LoginScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);

      // Login dengan kredensial valid
      final loginFields = find.byType(TextFormField);
      await tester.enterText(loginFields.at(0), 'owner');
      await tester.enterText(loginFields.at(1), 'secret');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Setelah login sukses, masuk ke ProjectFormPage
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // Buka drawer dari ProjectFormPage -> opsi Logout muncul (menggantikan Login)
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      final formDrawer = find.byType(LeftDrawer);
      final drawerLogout = find.descendant(
        of: formDrawer,
        matching: find.text('Logout'),
      );
      expect(drawerLogout, findsOneWidget);

      await tester.tap(drawerLogout);
      await tester.pumpAndSettle();
      expect(find.text('Berhasil logout.'), findsOneWidget);

      // Pastikan Home di drawer kembali ke MyHomePage
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'ProjectFormPage validates fields and submits snake_case JSON with Authorization Token',
    (WidgetTester tester) async {
      Map<String, dynamic>? capturedBody;
      Map<String, String>? capturedHeaders;

      final apiClient = _createMockApiClient(
        expectedAuthHeader: 'Token test-token-123',
        onCreateProject: (body, headers) {
          capturedBody = body;
          capturedHeaders = headers;
        },
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiClient>.value(value: apiClient),
            ChangeNotifierProvider<AuthState>(
              create: (_) =>
                  AuthState(apiClient, initialToken: 'test-token-123'),
            ),
          ],
          child: const MaterialApp(home: ProjectFormPage()),
        ),
      );

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Title cannot be empty!'), findsOneWidget);
      expect(find.text('Description cannot be empty!'), findsOneWidget);
      expect(find.text('Tech Stack cannot be empty!'), findsOneWidget);
      expect(find.text('Project URL cannot be empty!'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Mobile Portfolio');
      await tester.enterText(textFields.at(1), 'Integrated Flutter app.');
      await tester.enterText(textFields.at(2), 'Flutter, DRF');
      await tester.enterText(textFields.at(3), 'https://github.com/test/repo');
      await tester.pump();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(capturedHeaders?['Authorization'], 'Token test-token-123');
      expect(capturedBody?['title'], 'Mobile Portfolio');
      expect(capturedBody?['tech_stack'], 'Flutter, DRF');
      expect(capturedBody?['project_url'], 'https://github.com/test/repo');
      expect(capturedBody?.containsKey('id'), isFalse);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Title: Mobile Portfolio'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Project.fromJson and toJson handle snake_case keys and default projectImageUrl',
    (WidgetTester tester) async {
      final project = Project.fromJson({
        'id': 'abc-123',
        'title': 'DRF App',
        'description': 'REST API backend',
        'tech_stack': 'Django',
        'project_url': 'https://example.com',
      });
      expect(project.id, 'abc-123');
      expect(project.techStack, 'Django');
      expect(project.projectImageUrl, '');

      final json = project.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['tech_stack'], 'Django');
      expect(json['project_url'], 'https://example.com');
    },
  );

  testWidgets(
    'ExperienceFormPage validates inputs and renders summary AlertDialog on valid submit',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiClient>.value(value: _createMockApiClient()),
            ChangeNotifierProvider<AuthState>(
              create: (_) => AuthState(_createMockApiClient()),
            ),
          ],
          child: const MaterialApp(home: ExperienceFormPage()),
        ),
      );

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget,
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Software Engineering Intern');
      await tester.enterText(
        textFields.at(3),
        'Membangun fitur REST API Django dan UI Flutter.',
      );

      await tester.ensureVisible(textFields.at(1));
      await tester.tap(textFields.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Tutup'));
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

      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));
      expect(tester.takeException(), isNull);
      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.byType(ItemCard), findsNWidgets(4));

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
