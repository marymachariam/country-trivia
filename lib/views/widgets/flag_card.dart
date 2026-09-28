import 'package:flutter/material.dart';

import '../../data/services/image_cache_service.dart';

/// Displays a country flag image loaded from the CDN with caching support.
class FlagCard extends StatelessWidget {
  final String flagUrl;
  final ImageCacheService? cacheService;

  const FlagCard({
    super.key,
    required this.flagUrl,
    this.cacheService,
  });

  @override
  Widget build(BuildContext context) {
    final service = cacheService ?? ImageCacheService();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: service.buildCachedImage(
            url: flagUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
