import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_trivia/data/services/image_cache_service.dart';
import 'package:country_trivia/views/widgets/flag_card.dart';

/// A mock ImageCacheService for widget tests.
class MockImageCacheService extends ImageCacheService {
  final Widget Function(BuildContext, String)? customPlaceholder;
  final Widget Function(BuildContext, String, Object)? customErrorWidget;

  MockImageCacheService({
    this.customPlaceholder,
    this.customErrorWidget,
  });

  @override
  Widget buildCachedImage({
    required String url,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, Object)? errorWidget,
  }) {
    return Container(
      key: const Key('cached_image'),
      width: width ?? 320,
      height: height ?? 213,
      color: Colors.blue,
      child: const Center(
        child: Text('Mock Flag Image', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlagCard', () {
    const testFlagUrl = 'http://flagcdn.com/w320/us.png';

    testWidgets('renders with default cache service', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlagCard(flagUrl: testFlagUrl),
          ),
        ),
      );

      expect(find.byType(FlagCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with custom cache service', (WidgetTester tester) async {
      final mockService = MockImageCacheService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlagCard(
              flagUrl: testFlagUrl,
              cacheService: mockService,
            ),
          ),
        ),
      );

      expect(find.byType(FlagCard), findsOneWidget);
      expect(find.byKey(const Key('cached_image')), findsOneWidget);
      expect(find.text('Mock Flag Image'), findsOneWidget);
    });

    testWidgets('displays correct flag URL in mock', (WidgetTester tester) async {
      final mockService = MockImageCacheService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlagCard(
              flagUrl: testFlagUrl,
              cacheService: mockService,
            ),
          ),
        ),
      );

      final flagCard = tester.widget<FlagCard>(find.byType(FlagCard));
      expect(flagCard.flagUrl, equals(testFlagUrl));
    });

    testWidgets('renders Card with correct elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlagCard(flagUrl: testFlagUrl),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4));
    });

    testWidgets('renders with AspectRatio 3:2', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlagCard(flagUrl: testFlagUrl),
          ),
        ),
      );

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, closeTo(3 / 2, 0.01));
    });

    testWidgets('uses custom cache service when provided', (WidgetTester tester) async {
      final mockService = MockImageCacheService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlagCard(
              flagUrl: testFlagUrl,
              cacheService: mockService,
            ),
          ),
        ),
      );

      // The mock service should be used, so we should see the mock image
      expect(find.byKey(const Key('cached_image')), findsOneWidget);
    });

    testWidgets('renders ClipRRect for rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlagCard(flagUrl: testFlagUrl),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('handles different flag URLs', (WidgetTester tester) async {
      const urls = [
        'http://flagcdn.com/w320/us.png',
        'http://flagcdn.com/w320/gb.png',
        'http://flagcdn.com/w320/fr.png',
        'http://flagcdn.com/w320/de.png',
      ];

      for (final url in urls) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlagCard(
                flagUrl: url,
                cacheService: MockImageCacheService(),
              ),
            ),
          ),
        );

        final flagCard = tester.widget<FlagCard>(find.byType(FlagCard));
        expect(flagCard.flagUrl, equals(url));
      }
    });
  });
}
