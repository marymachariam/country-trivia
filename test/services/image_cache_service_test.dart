import 'dart:io';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:country_trivia/data/services/image_cache_service.dart';

/// A mock CacheManager for testing without touching the real cache.
class MockCacheManager extends CacheManager {
  final List<String> downloadedUrls = [];
  final List<String> clearedKeys = [];
  bool shouldThrowOnDownload = false;
  bool shouldThrowOnClear = false;

  MockCacheManager()
      : super(
          Config(
            'mockCacheKey',
            stalePeriod: const Duration(days: 1),
            maxNrOfCacheObjects: 10,
          ),
        );

  @override
  Future<FileInfo> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
  }) async {
    downloadedUrls.add(url);
    if (shouldThrowOnDownload) {
      throw Exception('Download failed');
    }
    return FileInfo(
      MemoryFileSystem().file(url),
      FileSource.Cache,
      DateTime.now().add(const Duration(days: 1)),
      url,
    );
  }

  @override
  Future<void> emptyCache() async {
    if (shouldThrowOnClear) {
      throw Exception('Clear failed');
    }
    clearedKeys.add('all');
  }

  @override
  Future<FileInfo?> getFileFromCache(String url, {bool ignoreMemCache = false}) async {
    return null;
  }

  @override
  Future<void> dispose() async {
    // No-op for mock
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider platform channel
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.createTempSync('cache_test').path;
      }
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return Directory.systemTemp.createTempSync('cache_test').path;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    log.clear();
  });

  group('ImageCacheService', () {
    late MockCacheManager mockCacheManager;
    late ImageCacheService service;

    setUp(() {
      mockCacheManager = MockCacheManager();
      service = ImageCacheService(cacheManager: mockCacheManager);
    });

    group('constructor', () {
      test('creates with default FlagCacheManager when no cacheManager provided', () {
        final defaultService = ImageCacheService();
        expect(defaultService, isNotNull);
      });

      test('creates with provided cacheManager', () {
        expect(service, isNotNull);
      });
    });

    group('buildCachedImage', () {
      test('returns a CachedNetworkImage widget', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
        );
        expect(widget, isNotNull);
      });

      test('accepts custom fit parameter', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
          fit: BoxFit.contain,
        );
        expect(widget, isNotNull);
      });

      test('accepts custom width and height', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
          width: 200,
          height: 150,
        );
        expect(widget, isNotNull);
      });

      test('accepts custom placeholder', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
          placeholder: (context, url) => const Text('Loading...'),
        );
        expect(widget, isNotNull);
      });

      test('accepts custom errorWidget', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
          errorWidget: (context, url, error) => const Text('Error'),
        );
        expect(widget, isNotNull);
      });

      test('accepts custom imageBuilder', () {
        final widget = service.buildCachedImage(
          url: 'http://flagcdn.com/w320/us.png',
          imageBuilder: (context, imageProvider) => Container(),
        );
        expect(widget, isNotNull);
      });
    });

    group('preloadImages', () {
      test('downloads all provided URLs', () async {
        final urls = [
          'http://flagcdn.com/w320/us.png',
          'http://flagcdn.com/w320/gb.png',
          'http://flagcdn.com/w320/fr.png',
        ];

        await service.preloadImages(urls);

        expect(mockCacheManager.downloadedUrls.length, equals(3));
        expect(mockCacheManager.downloadedUrls, containsAll(urls));
      });

      test('handles empty URL list gracefully', () async {
        await service.preloadImages([]);
        expect(mockCacheManager.downloadedUrls, isEmpty);
      });

      test('silently skips failed downloads', () async {
        mockCacheManager.shouldThrowOnDownload = true;

        final urls = [
          'http://flagcdn.com/w320/us.png',
          'http://flagcdn.com/w320/gb.png',
        ];

        // Should not throw
        await service.preloadImages(urls);
      });

      test('continues preloading after a failure', () async {
        mockCacheManager.shouldThrowOnDownload = true;

        final urls = [
          'http://flagcdn.com/w320/us.png',
          'http://flagcdn.com/w320/gb.png',
        ];

        await service.preloadImages(urls);

        // All URLs should have been attempted
        expect(mockCacheManager.downloadedUrls.length, equals(2));
      });
    });

    group('clearCache', () {
      test('clears the cache successfully', () async {
        await service.clearCache();
        expect(mockCacheManager.clearedKeys, contains('all'));
      });

      test('propagates exceptions from cache manager', () async {
        mockCacheManager.shouldThrowOnClear = true;

        expect(
          () => service.clearCache(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCacheSize', () {
      test('returns an integer', () async {
        final size = await service.getCacheSize();
        expect(size, isA<int>());
      });
    });

    group('getCachedObjectCount', () {
      test('returns an integer', () async {
        final count = await service.getCachedObjectCount();
        expect(count, isA<int>());
      });

      test('returns 0 when cache is empty', () async {
        final count = await service.getCachedObjectCount();
        expect(count, equals(0));
      });
    });

    group('dispose', () {
      test('disposes without throwing', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });

  group('FlagCacheManager', () {
    test('returns singleton instance', () {
      final instance1 = FlagCacheManager();
      final instance2 = FlagCacheManager();
      expect(identical(instance1, instance2), isTrue);
    });

    test('has correct cache key', () {
      expect(FlagCacheManager.key, equals('flagCacheKey'));
    });
  });
}
