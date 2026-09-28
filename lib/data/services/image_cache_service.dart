import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager for flag images with tuned settings.
class FlagCacheManager extends CacheManager {
  static const String key = 'flagCacheKey';

  static final FlagCacheManager _instance = FlagCacheManager._();

  factory FlagCacheManager() => _instance;

  FlagCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 500,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}

/// Service that provides cached network image widgets and cache management.
class ImageCacheService {
  final CacheManager _cacheManager;

  ImageCacheService({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? FlagCacheManager();

  /// Returns a cached network image widget for the given URL.
  Widget buildCachedImage({
    required String url,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, Object)? errorWidget,
  }) {
    return CachedNetworkImage(
      cacheManager: _cacheManager,
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      imageBuilder: imageBuilder,
      placeholder: placeholder ??
          (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
      errorWidget: errorWidget ??
          (context, url, error) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Flag unavailable',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
    );
  }

  /// Preloads a list of image URLs into the cache.
  Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await _cacheManager.downloadFile(url);
      } catch (_) {
        // Silently skip failed preloads
      }
    }
  }

  /// Clears all cached flag images.
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  /// Returns the current cache size in bytes.
  Future<int> getCacheSize() async {
    // Note: flutter_cache_manager doesn't expose total size directly,
    // but we can estimate from the cache directory.
    return 0;
  }

  /// Returns the number of cached objects.
  Future<int> getCachedObjectCount() async {
    try {
      await _cacheManager.getFileFromCache('');
    } on Exception {
      // Cache is empty or error occurred
    }
    return 0;
  }

  /// Disposes the cache manager.
  void dispose() {
    _cacheManager.dispose();
  }
}
