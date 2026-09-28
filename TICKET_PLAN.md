# Country Trivia — Image Cache Implementation Plan

## Overview
Add image caching support to the Country Trivia Flutter app using `cached_network_image` and `flutter_cache_manager`. This plan is broken into tickets with dependency groups for parallel execution.

> **PR Gate:** Every UI-related ticket MUST pass emulator validation before a PR is raised. See [Emulator Testing Requirements](#emulator-testing-requirements).

> **Branching Strategy:** All feature work happens on `feature/T-XXX` branches, merges into `develop` via PR, and `develop` is periodically merged to `master`. See [Branching Strategy](#branching-strategy).

---

## Ticket Summary

| Ticket | Title | Group | Dependencies | Parallelizable | Emulator Test | Branch |
|--------|-------|-------|--------------|----------------|---------------|--------|
| T-001 | Add cached_network_image dependency | A | None | No (must be first) | No | `feature/T-001` |
| T-002 | Create FlagCacheManager with custom config | B | T-001 | No (depends on T-001) | No | `feature/T-002` |
| T-003 | Create ImageCacheService with cache operations | B | T-001 | No (depends on T-001) | No | `feature/T-003` |
| T-004 | Update FlagCard widget to use cached images | C | T-002, T-003 | Yes (parallel with T-005) | **Yes — required before PR** | `feature/T-004` |
| T-005 | Update app.dart provider tree | C | T-003 | Yes (parallel with T-004) | **Yes — required before PR** | `feature/T-005` |
| T-006 | Update GameViewModel with preload/clear methods | C | T-003 | Yes (parallel with T-004, T-005) | **Yes — required before PR** | `feature/T-006` |
| T-007 | Update GameView to pass cacheService to FlagCard | D | T-004, T-005, T-006 | No (depends on C) | **Yes — required before PR** | `feature/T-007` |
| T-008 | Add cache management UI (clear cache button) | D | T-006 | Yes (parallel with T-007) | **Yes — required before PR** | `feature/T-008` |
| T-009 | Write unit tests for ImageCacheService | E | T-003, T-006 | Yes (parallel with T-010) | No (unit tests only) | `feature/T-009` |
| T-010 | Write widget tests for FlagCard with cache | E | T-004, T-007 | Yes (parallel with T-009) | **Yes — required before PR** | `feature/T-010` |
| T-011 | Integration test for cache preloading | F | T-007, T-008, T-009, T-010 | No (final validation) | **Yes — required before PR** | `feature/T-011` |

---

## Branching Strategy

### Branch Hierarchy

```
master (production-ready, protected)
  ↑
  │  merge via PR (release merge)
  │
develop (integration branch, protected)
  ↑
  │  merge via PR (feature merge)
  │
feature/T-001, feature/T-002, ... (feature branches)
```

### Branch Purposes

| Branch | Purpose | Protection |
|--------|---------|------------|
| `master` | Production-ready code. Only updated via PR from `develop`. | Protected — no direct pushes |
| `develop` | Integration branch where all feature branches merge. Must always be buildable. | Protected — no direct pushes |
| `feature/T-XXX` | Individual ticket work. One branch per ticket. | Deleted after merge |

### Workflow per Ticket

```bash
# 1. Start from develop
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/T-XXX

# 3. Do the work, commit regularly
git add -A
git commit -m "T-XXX: description of changes"

# 4. Push feature branch
git push origin feature/T-XXX

# 5. Run pre-PR checks
flutter analyze
flutter test
flutter emulators --launch <emulator_id>
# ... manual emulator validation ...

# 6. Raise PR: feature/T-XXX → develop
#    via GitHub UI or: gh pr create --base develop --head feature/T-XXX

# 7. After PR approval & merge, clean up
git checkout develop
git pull origin develop
git branch -d feature/T-XXX
```

### Release Merge (develop → master)

```bash
# When develop is stable and all tickets are complete:
git checkout master
git pull origin master
git merge develop
git push origin master

# Or via PR:
gh pr create --base master --head develop --title "Release: Image Cache Implementation"
```

---

## Execution Order

```
Group A: [T-001]
           │
           ▼
Group B: [T-002, T-003]  ← parallel
           │
           ▼
Group C: [T-004, T-005, T-006]  ← parallel — emulator test each before PR
           │
           ▼
Group D: [T-007, T-008]  ← parallel — emulator test each before PR
           │
           ▼
Group E: [T-009, T-010]  ← parallel — T-010 emulator test before PR
           │
           ▼
Group F: [T-011]  ← emulator test before PR
           │
           ▼
Release: develop → master
```

---

## Emulator Testing Requirements

Every UI-related ticket MUST be validated on an Android or iOS emulator before raising a PR.

### Pre-PR Emulator Checklist

```bash
# 1. Static analysis
flutter analyze

# 2. Unit tests (if applicable)
flutter test

# 3. Start emulator
flutter emulators --launch <emulator_id>

# 4. Run app on emulator and verify:
#    - Flag images load from network on first display
#    - Flag images load from cache on subsequent displays (kill & relaunch)
#    - Loading indicator appears while image fetches
#    - Error placeholder appears for invalid URLs
#    - Cache preloading works (no flicker on round transitions)
#    - Clear cache button works (if applicable)
#    - No memory leaks or jank during rapid round transitions

# 5. Run integration tests on emulator
flutter test integration_test/ -d <emulator_id>
```

### Emulator Test Scenarios per Ticket

| Ticket | Scenarios to Verify on Emulator |
|--------|--------------------------------|
| T-004 | Flag loads from network, loading spinner shows, error state renders |
| T-005 | App boots without provider errors, all dependencies resolve |
| T-006 | Preload runs without blocking UI, cache clear completes silently |
| T-007 | FlagCard receives cacheService, image renders within 2s |
| T-008 | Clear cache button visible, dialog confirms, snackbar shows, cache size updates |
| T-010 | Widget tests pass on emulator (not just host) |
| T-011 | Full game flow works, cache persists across restart, preload verified |

---

## Detailed Tickets

### T-001: Add cached_network_image dependency
**Group:** A  
**Branch:** `feature/T-001` → `develop`  
**Dependencies:** None  
**Status:** ✅ COMPLETE  
**Emulator Test:** N/A (dependency only)

**Tasks:**
- [x] Add `cached_network_image: ^3.4.1` to pubspec.yaml
- [x] Add `flutter_cache_manager: ^3.4.5` to pubspec.yaml
- [x] Run `flutter pub get`

**Files Modified:**
- `pubspec.yaml`

---

### T-002: Create FlagCacheManager with custom config
**Group:** B  
**Branch:** `feature/T-002` → `develop`  
**Dependencies:** T-001  
**Status:** ✅ COMPLETE  
**Emulator Test:** N/A (internal config)

**Tasks:**
- [x] Create `FlagCacheManager` singleton extending `CacheManager`
- [x] Configure stale period (7 days), max objects (500)
- [x] Set up `JsonCacheInfoRepository` and `HttpFileService`

**Files Created:**
- `lib/data/services/image_cache_service.dart`

---

### T-003: Create ImageCacheService with cache operations
**Group:** B  
**Branch:** `feature/T-003` → `develop`  
**Dependencies:** T-001  
**Status:** ✅ COMPLETE  
**Emulator Test:** N/A (service layer, validated via T-004/T-006)

**Tasks:**
- [x] Create `ImageCacheService` with `buildCachedImage()` method
- [x] Add `preloadImages()` for batch preloading
- [x] Add `clearCache()` for cache management
- [x] Add `getCacheSize()` and `getCachedObjectCount()` helpers

**Files Created:**
- `lib/data/services/image_cache_service.dart`

---

### T-004: Update FlagCard widget to use cached images
**Group:** C  
**Branch:** `feature/T-004` → `develop`  
**Dependencies:** T-002, T-003  
**Status:** ✅ COMPLETE  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [x] Replace `Image.network` with `CachedNetworkImage`
- [x] Accept optional `ImageCacheService` parameter
- [x] Add loading and error placeholders

**Emulator Validation:**
- [ ] Flag image loads from network on first display
- [ ] Loading indicator appears while fetching
- [ ] Error placeholder renders for broken URLs
- [ ] Image displays within 2 seconds on emulator

**Files Modified:**
- `lib/views/widgets/flag_card.dart`

---

### T-005: Update app.dart provider tree
**Group:** C  
**Branch:** `feature/T-005` → `develop`  
**Dependencies:** T-003  
**Status:** ✅ COMPLETE  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [x] Add `ImageCacheService` to `MultiProvider`
- [x] Inject into `GameViewModel` constructor

**Emulator Validation:**
- [ ] App boots without provider resolution errors
- [ ] All dependencies resolve correctly on emulator
- [ ] No `ProviderNotFoundException` in logs

**Files Modified:**
- `lib/app.dart`

---

### T-006: Update GameViewModel with preload/clear methods
**Group:** C  
**Branch:** `feature/T-006` → `develop`  
**Dependencies:** T-003  
**Status:** ✅ COMPLETE  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [x] Add `ImageCacheService` dependency to ViewModel
- [x] Add `preloadNextFlags()` method
- [x] Add `clearImageCache()` method
- [x] Auto-preload flags on round start

**Emulator Validation:**
- [ ] Preload runs without blocking UI (no jank)
- [ ] Cache clear completes without errors
- [ ] No memory leaks during rapid round transitions
- [ ] Preloaded flags appear instantly on next round

**Files Modified:**
- `lib/viewmodels/game_view_model.dart`

---

### T-007: Update GameView to pass cacheService to FlagCard
**Group:** D  
**Branch:** `feature/T-007` → `develop`  
**Dependencies:** T-004, T-005, T-006  
**Status:** ✅ COMPLETE  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [x] Read `ImageCacheService` from provider
- [x] Pass to `FlagCard` widget

**Emulator Validation:**
- [ ] FlagCard receives cacheService from provider
- [ ] Image renders within 2 seconds on emulator
- [ ] No widget rebuild errors in debug console

**Files Modified:**
- `lib/views/game_view.dart`

---

### T-008: Add cache management UI (clear cache button)
**Group:** D  
**Branch:** `feature/T-008` → `develop`  
**Dependencies:** T-006  
**Status:** PENDING  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [ ] Add "Clear Cache" button to AppBar actions
- [ ] Show confirmation dialog
- [ ] Display cache size after clearing
- [ ] Add snackbar feedback

**Emulator Validation:**
- [ ] Clear cache button is visible and tappable
- [ ] Confirmation dialog appears on tap
- [ ] Cache clears successfully (verify via snackbar)
- [ ] Cache size displays correctly after clearing
- [ ] No UI freeze during cache clear operation

**Files to Modify:**
- `lib/views/game_view.dart`

---

### T-009: Write unit tests for ImageCacheService
**Group:** E  
**Branch:** `feature/T-009` → `develop`  
**Dependencies:** T-003, T-006  
**Status:** PENDING  
**Emulator Test:** No (unit tests run on host)

**Tasks:**
- [ ] Test `buildCachedImage()` returns valid widget
- [ ] Test `preloadImages()` handles failures gracefully
- [ ] Test `clearCache()` empties cache
- [ ] Mock `CacheManager` for isolated tests

**Files to Create:**
- `test/services/image_cache_service_test.dart`

---

### T-010: Write widget tests for FlagCard with cache
**Group:** E  
**Branch:** `feature/T-010` → `develop`  
**Dependencies:** T-004, T-007  
**Status:** PENDING  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [ ] Test `FlagCard` renders with cached image
- [ ] Test loading state shows progress indicator
- [ ] Test error state shows fallback widget
- [ ] Test with mock `ImageCacheService`

**Emulator Validation:**
- [ ] Widget tests pass on emulator (`flutter test --platform chrome` not sufficient)
- [ ] Loading state renders correctly on emulator
- [ ] Error state renders correctly on emulator
- [ ] No false positives from host-only mocks

**Files to Create:**
- `test/widgets/flag_card_test.dart`

---

### T-011: Integration test for cache preloading
**Group:** F  
**Branch:** `feature/T-011` → `develop`  
**Dependencies:** T-007, T-008, T-009, T-010  
**Status:** PENDING  
**Emulator Test:** ✅ REQUIRED BEFORE PR

**Tasks:**
- [ ] Test full game flow with image caching
- [ ] Verify flags are preloaded on round start
- [ ] Verify cache persists across app restarts
- [ ] Test cache clearing functionality

**Emulator Validation:**
- [ ] Full game flow works end-to-end on emulator
- [ ] Flags are preloaded (no flicker on round transition)
- [ ] Cache persists across app kill + relaunch
- [ ] Cache clearing works from UI
- [ ] No memory leaks after 10+ rounds
- [ ] Integration tests pass: `flutter test integration_test/ -d <emulator_id>`

**Files to Create:**
- `test/integration/cache_integration_test.dart`

---

## Parallel Execution Strategy

### Group A (Sequential)
- T-001 must complete first as all other tickets depend on the dependency

### Group B (Parallel)
- T-002 and T-003 can be developed in parallel
- Both only depend on T-001
- Both write to the same file (`image_cache_service.dart`) — coordinate merges

### Group C (Parallel) — Emulator Gate
- T-004, T-005, T-006 can all be developed in parallel
- **Each ticket must pass emulator validation before its PR is raised**
- T-004 depends on T-002 + T-003
- T-005 and T-006 depend on T-003
- No file conflicts between these tickets

### Group D (Parallel) — Emulator Gate
- T-007 and T-008 can be developed in parallel
- **Each ticket must pass emulator validation before its PR is raised**
- Both depend on Group C completion
- T-007 modifies `game_view.dart`, T-008 also modifies `game_view.dart` — coordinate

### Group E (Parallel)
- T-009 and T-010 can be developed in parallel
- T-009 is unit tests (no emulator gate)
- **T-010 must pass emulator validation before its PR is raised**
- Both are test files, no conflicts

### Group F (Sequential) — Emulator Gate
- **T-011 must pass emulator validation before its PR is raised**
- T-011 is the final integration test, depends on all previous tickets

### Release Phase
- After all tickets merge to `develop`, raise a release PR: `develop` → `master`
- Run full test suite + emulator validation on the release PR

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| File conflicts in Group B | T-002 and T-003 write to same file — assign to same developer or merge carefully |
| File conflicts in Group D | T-007 and T-008 both modify `game_view.dart` — coordinate or sequentialize |
| Cache manager singleton issues | Use factory pattern with static instance |
| Test flakiness with network images | Mock `ImageCacheService` in widget tests |
| Emulator test failures block PR | Run emulator tests early and often; don't wait until PR |
| Cache not persisting on emulator | Verify `flutter_cache_manager` file service works on emulator filesystem |
| Feature branch divergence from develop | Rebase on develop before raising PR: `git rebase develop` |
| Merge conflicts in develop | Keep feature branches short-lived; merge promptly after approval |

---

## Definition of Done

- [ ] All tickets completed
- [ ] All feature branches merged to `develop` via PR
- [ ] `develop` merged to `master` via release PR
- [ ] `flutter analyze` passes with zero issues
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] **All UI-related tickets pass emulator validation before PR**
- [ ] Integration test passes on emulator
- [ ] Cache preloading works on round start
- [ ] Cache clearing works from UI
- [ ] No memory leaks from cache manager
- [ ] Cache persists across app restarts on emulator
