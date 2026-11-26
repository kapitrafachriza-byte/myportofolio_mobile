import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
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
  List<Map<String, dynamic>>? experiencesPayload,
  int experiencesGetStatusCode = 200,
  int experiencePostStatusCode = 201,
  int experienceDeleteStatusCode = 204,
  String? expectedAuthHeader,
  void Function(Map<String, dynamic> body, Map<String, String> headers)?
  onCreateProject,
  void Function(Map<String, dynamic> body, Map<String, String> headers)?
  onCreateExperience,
  void Function(String id, Map<String, String> headers)? onDeleteExperience,
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

  final sampleExperiences =
      experiencesPayload ??
      [
        {
          'id': 'aaaa1111-1111-1111-1111-111111111111',
          'title': 'Software Engineering Intern',
          'description': 'Developing backend features with Django and DRF.',
          'category': 'internship',
          'category_display': 'Internship',
          'thumbnail': null,
          'started_at': '2026-06-01T00:00:00Z',
          'ended_at': null,
          'is_ongoing': true,
          'star_count': 3,
          'is_starred': false,
          'starred_by_names': 'alice, bob',
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
    if (request.url.path == '/api/v1/experiences/' && request.method == 'GET') {
      return http.Response(
        jsonEncode(sampleExperiences),
        experiencesGetStatusCode,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path == '/api/v1/experiences/' &&
        request.method == 'POST') {
      if (experiencePostStatusCode >= 400) {
        return http.Response('{"detail": "Error"}', experiencePostStatusCode);
      }
      if (expectedAuthHeader != null &&
          request.headers['Authorization'] != expectedAuthHeader) {
        return http.Response('{"detail": "Unauthorized"}', 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      onCreateExperience?.call(body, request.headers);
      return http.Response(
        jsonEncode({
          'id': 'bbbb2222-2222-2222-2222-222222222222',
          'title': body['title'],
          'description': body['description'],
          'category': body['category'],
          'category_display': 'Internship',
          'thumbnail': body['thumbnail'],
          'started_at': '2026-11-26T10:00:00Z',
          'ended_at': body['ended_at'],
          'is_ongoing': body['ended_at'] == null,
          'star_count': 0,
          'is_starred': false,
          'starred_by_names': '',
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path.startsWith('/api/v1/experiences/') &&
        request.method == 'DELETE') {
      if (experienceDeleteStatusCode >= 400) {
        return http.Response('{"detail": "Error"}', experienceDeleteStatusCode);
      }
      if (expectedAuthHeader != null &&
          request.headers['Authorization'] != expectedAuthHeader) {
        return http.Response('{"detail": "Unauthorized"}', 401);
      }
      final segments = request.url.pathSegments.where((s) => s.isNotEmpty);
      final id = segments.last;
      onDeleteExperience?.call(id, request.headers);
      return http.Response('', 204);
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
    'MyPortfolio renders owner InfoCards, 5 distinct colored ItemCards, and Logout SnackBar',
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
        'Lihat Experience',
        'Tambah Experience',
        'Logout',
      ];
      for (final label in expectedButtons) {
        expect(find.text(label), findsOneWidget);
      }

      final itemCardWidgets = tester
          .widgetList<ItemCard>(find.byType(ItemCard))
          .toList();
      expect(itemCardWidgets.length, 5);

      final cardColors = <Color?>{};
      for (final itemCard in itemCardWidgets) {
        final materialFinder = find.descendant(
          of: find.byWidget(itemCard),
          matching: find.byType(Material),
        );
        final materialWidget = tester.widget<Material>(materialFinder.first);
        cardColors.add(materialWidget.color);
      }
      expect(cardColors.length, 5);

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
    'Public ExperienceListScreen loads entries, navigates to ExperienceDetailScreen, and handles empty state',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

      await tester.tap(find.text('Lihat Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('Software Engineering Intern'), findsOneWidget);
      expect(find.text('Internship • Ongoing'), findsOneWidget);

      await tester.tap(find.text('Software Engineering Intern'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceDetailScreen), findsOneWidget);
      expect(find.text('Internship'), findsOneWidget);
      expect(
        find.text('Period: 2026-06-01 - Masih berlangsung'),
        findsOneWidget,
      );
      expect(
        find.text('Developing backend features with Django and DRF.'),
        findsOneWidget,
      );
      expect(find.text('Stars: 3'), findsOneWidget);
      expect(find.text('Starred by: alice, bob'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets(
    'ExperienceListScreen shows empty state when API returns no experiences',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(apiClient: _createMockApiClient(experiencesPayload: const [])),
      );
      await tester.tap(find.text('Lihat Experience'));
      await tester.pumpAndSettle();
      expect(find.text('No experiences found.'), findsOneWidget);
    },
  );

  testWidgets(
    'ExperienceListScreen shows Retry on API error and recovers when retried',
    (WidgetTester tester) async {
      var shouldFail = true;
      final mockHttp = MockClient((request) async {
        if (request.url.path == '/api/v1/experiences/' &&
            request.method == 'GET') {
          if (shouldFail) {
            return http.Response('Server Error', 500);
          }
          return http.Response(
            jsonEncode([
              {
                'id': 'aaaa1111-1111-1111-1111-111111111111',
                'title': 'Recovered Research Assistant',
                'description': 'ML systems lab research.',
                'category': 'research',
                'category_display': 'Research',
                'thumbnail': '',
                'started_at': '2026-02-01T00:00:00Z',
                'ended_at': '2026-05-01T00:00:00Z',
                'is_ongoing': false,
                'star_count': 1,
                'is_starred': false,
                'starred_by_names': '',
              },
            ]),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(
        client: mockHttp,
        baseUrl: 'http://localhost:8000',
      );
      await tester.pumpWidget(MyApp(apiClient: apiClient));

      await tester.tap(find.text('Lihat Experience'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Failed to load experiences:'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      shouldFail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Recovered Research Assistant'), findsOneWidget);
      expect(find.text('Research • Completed'), findsOneWidget);
    },
  );

  testWidgets(
    'ExperienceDetailScreen supports authenticated DELETE and refreshes ExperienceListScreen',
    (WidgetTester tester) async {
      String? deletedId;
      String? authHeader;
      final experiences = [
        {
          'id': 'exp-delete-1',
          'title': 'Temporary Role',
          'description': 'To be deleted.',
          'category': 'volunteer',
          'category_display': 'Volunteer',
          'thumbnail': '',
          'started_at': '2026-01-10T00:00:00Z',
          'ended_at': null,
          'is_ongoing': true,
          'star_count': 0,
          'is_starred': false,
          'starred_by_names': '',
        },
      ];

      final mockHttp = MockClient((request) async {
        if (request.url.path == '/api/v1/experiences/' &&
            request.method == 'GET') {
          return http.Response(jsonEncode(experiences), 200);
        }
        if (request.url.path == '/api/v1/experiences/exp-delete-1/' &&
            request.method == 'DELETE') {
          deletedId = 'exp-delete-1';
          authHeader = request.headers['Authorization'];
          experiences.clear();
          return http.Response('', 204);
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(
        client: mockHttp,
        baseUrl: 'http://localhost:8000',
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
          child: const MaterialApp(home: ExperienceListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Temporary Role'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete Experience'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Experience?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(deletedId, 'exp-delete-1');
      expect(authHeader, 'Token test-token-123');
      expect(find.byType(ExperienceListScreen), findsOneWidget);
      expect(find.text('No experiences found.'), findsOneWidget);
    },
  );

  testWidgets(
    'Auth guard redirects unauthenticated Add Project and Add Experience to LoginScreen, then allows drawer Logout',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: _createMockApiClient()));

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
        find.descendant(of: drawerFinder, matching: find.text('Experiences')),
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
        find.descendant(
          of: drawerFinder,
          matching: find.text('Add Experience'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);

      final loginFields = find.byType(TextFormField);
      await tester.enterText(loginFields.at(0), 'owner');
      await tester.enterText(loginFields.at(1), 'secret');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);

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

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(LeftDrawer),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'ExperienceFormPage validates fields, submits snake_case JSON with token, and opens ExperienceListScreen',
    (WidgetTester tester) async {
      Map<String, dynamic>? capturedBody;
      Map<String, String>? capturedHeaders;

      final apiClient = _createMockApiClient(
        expectedAuthHeader: 'Token test-token-123',
        onCreateExperience: (body, headers) {
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
          child: const MaterialApp(home: ExperienceFormPage()),
        ),
      );

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget,
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Backend Developer Intern');
      await tester.enterText(
        textFields.at(2),
        'Built REST endpoints with DRF and TokenAuth.',
      );
      await tester.enterText(textFields.at(3), 'invalid-url');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      expect(
        find.text(
          'Format URL tidak valid! Gunakan awalan http:// atau https://',
        ),
        findsOneWidget,
      );

      await tester.enterText(textFields.at(3), 'https://example.com/badge.png');
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(capturedHeaders?['Authorization'], 'Token test-token-123');
      expect(capturedBody?['title'], 'Backend Developer Intern');
      expect(capturedBody?['category'], 'internship');
      expect(capturedBody?['thumbnail'], 'https://example.com/badge.png');
      expect(capturedBody?.containsKey('id'), isFalse);
      expect(capturedBody?.containsKey('started_at'), isFalse);
      expect(capturedBody?.containsKey('is_ongoing'), isFalse);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Lihat Daftar'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'ExperienceFormPage clears session and prompts LoginScreen on 401 response',
    (WidgetTester tester) async {
      final apiClient = _createMockApiClient(experiencePostStatusCode: 401);
      final authState = AuthState(apiClient, initialToken: 'expired-token');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiClient>.value(value: apiClient),
            ChangeNotifierProvider<AuthState>.value(value: authState),
          ],
          child: const MaterialApp(home: ExperienceFormPage()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Expired Session Test');
      await tester.enterText(textFields.at(2), 'Testing 401 handling.');

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(authState.isLoggedIn, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Session expired. Please login again.'), findsOneWidget);
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

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Project and Experience JSON serialization exclude server-assigned fields',
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

      final projectJson = project.toJson();
      expect(projectJson.containsKey('id'), isFalse);
      expect(projectJson['tech_stack'], 'Django');
      expect(projectJson['project_url'], 'https://example.com');

      final experience = Experience.fromJson({
        'id': 'exp-123',
        'title': 'Research Intern',
        'description': 'Published paper',
        'category': 'research',
        'category_display': 'Research',
        'thumbnail': null,
        'started_at': '2026-03-01T00:00:00Z',
        'ended_at': null,
        'is_ongoing': true,
        'star_count': 5,
        'is_starred': true,
        'starred_by_names': 'owner',
      });
      expect(experience.id, 'exp-123');
      expect(experience.categoryDisplay, 'Research');
      expect(experience.thumbnail, '');
      expect(experience.isOngoing, isTrue);
      expect(experience.starCount, 5);

      final expJson = experience.toJson();
      expect(expJson.containsKey('id'), isFalse);
      expect(expJson.containsKey('started_at'), isFalse);
      expect(expJson.containsKey('category_display'), isFalse);
      expect(expJson.containsKey('is_ongoing'), isFalse);
      expect(expJson.containsKey('star_count'), isFalse);
      expect(expJson['title'], 'Research Intern');
      expect(expJson['category'], 'research');
    },
  );

  testWidgets(
    'MyHomePage, ExperienceListScreen, and ExperienceFormPage render cleanly without overflow on narrow mobile viewport (360x800)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final apiClient = _createMockApiClient();
      await tester.pumpWidget(MyApp(apiClient: apiClient));
      expect(tester.takeException(), isNull);
      expect(find.byType(InfoCard), findsNWidgets(3));
      expect(find.byType(ItemCard), findsNWidgets(5));

      await tester.tap(find.text('Lihat Experience'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ExperienceListScreen), findsOneWidget);
    },
  );
}
