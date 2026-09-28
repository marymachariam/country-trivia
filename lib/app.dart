import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/country_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/image_cache_service.dart';
import 'data/services/storage_service.dart';
import 'viewmodels/game_view_model.dart';
import 'views/game_view.dart';

/// Root widget that sets up the provider tree and theme.
class CountryTriviaApp extends StatelessWidget {
  const CountryTriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (singletons for the app's lifetime)
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ImageCacheService>(create: (_) => ImageCacheService()),

        // Repository depends on both services
        ProxyProvider2<ApiService, StorageService, CountryRepository>(
          update: (_, api, storage, _) => CountryRepository(
            apiService: api,
            storageService: storage,
          ),
        ),

        // ViewModel depends on the repository and image cache service
        ChangeNotifierProvider<GameViewModel>(
          create: (context) => GameViewModel(
            repository: context.read<CountryRepository>(),
            imageCacheService: context.read<ImageCacheService>(),
          )..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Country Trivia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const GameView(),
      ),
    );
  }
}
