# AGENTS.md

## Project

Flutter Country Trivia game using MVVM + Provider. Fetches country data from RestCountries API, displays flags from flagcdn.com, persists score and solved flags via SharedPreferences.

## Commands

```bash
# Analyze (must pass with zero issues)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/services/image_cache_service_test.dart

# Get dependencies
flutter pub get
```

## Architecture

- `lib/main.dart` → `lib/app.dart` (Provider tree) → `lib/views/game_view.dart`
- `lib/viewmodels/game_view_model.dart` — all game state and logic
- `lib/data/repositories/country_repository.dart` — mediates API ↔ storage
- `lib/data/services/` — `api_service.dart` (HTTP), `storage_service.dart` (SharedPreferences), `image_cache_service.dart` (flag caching)
- `lib/core/constants/api_constants.dart` — API URLs and flag CDN base

## Branching

- Feature branches: `feature/T-XXX` → merge to `develop` via PR
- Release: `develop` → `master` via PR
- See `TICKET_PLAN.md` for full ticket breakdown and parallel execution groups

## Testing

- `flutter analyze` must pass with zero issues before any PR
- `flutter test` must pass before any PR
- UI-related tickets require emulator validation before PR (see TICKET_PLAN.md)
- Unit tests that use `CacheManager` must mock `path_provider` platform channel and call `TestWidgetsFlutterBinding.ensureInitialized()`

## Dependencies

- `provider` — state management
- `http` — API calls
- `shared_preferences` — persistence
- `cached_network_image` + `flutter_cache_manager` — flag image caching
- `file` (dev) — filesystem abstraction for tests
