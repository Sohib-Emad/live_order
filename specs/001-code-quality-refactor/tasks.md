---

description: "Task list for codebase quality refactoring"

---

# Tasks: Codebase Quality Refactoring

**Input**: Design documents from `specs/001-code-quality-refactor/`

**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup & Audit

**Purpose**: Verify current state, capture baseline metrics, configure tooling

- [x] T001 Baseline lint check: `flutter analyze` — no issues found ✅
- [x] T002 Baseline test run: `flutter test` — 27 tests passed ✅
- [x] T003 [P] Create `test/helpers/` directory with mock repo base class + test data generators ✅

---

## Phase 2: Foundational — Core Cleanup (Blocking Prerequisites)

**Purpose**: Fix shared/core infrastructure issues that block feature-level work

**⚠️ CRITICAL**: No feature-level refactoring can begin until this phase is complete

- [x] T004 [P] Review `lib/core/di/di.dart` — registration order is correct: APIs → Repos → Cubits ✅
- [x] T005 [P] Remove `debugPrint()` — 3 calls migrated to AppLogger (premium_order_map_widget.dart, live_chat_sheet.dart) ✅
- [x] T006 [P] Remove unused imports/fields — `dart fix --dry-run` & `flutter analyze` = 0 issues ✅
- [x] T007 [P] Fix `.withOpacity()` calls — none found (already cleaned) ✅

---

## Phase 3: Architecture & Layer Compliance (US1)

**Goal**: Ensure every feature follows Clean Architecture layering — UI → Logic → Data with no bypassing

**Independent Test**: grep for direct API imports from UI or Cubit files; `flutter analyze` shows zero dependency violations

### Implementation

- [x] T008 [P] [US1] `lib/features/auth/` — Compliant ✅
- [x] T009 [P] [US1] `lib/features/session/` — Fixed: Cubit now gets uid from repo, uses repo for chat streams. UI uses cubit.signOut() ✅
- [x] T010 [P] [US1] `lib/features/user_home/` — Compliant ✅
- [x] T011 [P] [US1] `lib/features/user_tracking/` — Compliant ✅
- [x] T012 [P] [US1] `lib/features/user_chat/` — Fixed: Cubit now calls repo for order check instead of direct Supabase ✅
- [x] T013 [P] [US1] `lib/features/user_account/` — Compliant ✅
- [x] T014 [P] [US1] `lib/features/user_drivers/` — Fixed: reportDriver dialog now uses DriversCubit instead of direct Supabase insert ✅
- [x] T015 [P] [US1] `lib/features/user_create_shipment/` — Compliant ✅
- [x] T016 [P] [US1] `lib/features/user_payments/` — UI imports only from state (not direct data/model), no layer violation ✅
- [x] T017 [P] [US1] `lib/features/user_rewards/` — Compliant ✅
- [x] T018 [P] [US1] `lib/features/user_notifications/` — Compliant ✅
- [x] T019 [P] [US1] `lib/features/user_rate_driver/` — Compliant ✅
- [x] T020 [P] [US1] `lib/features/driver_home/` — Fixed: UI streams now go through DriverRepo, availability toggle through DriverCubit ✅
- [x] T021 [P] [US1] `lib/features/driver_orders/` — Fixed: UI streams now go through AddOrderCubit ✅
- [x] T022 [P] [US1] `lib/features/driver_chat/` — Fixed: UI uses ChatCubit instead of direct ChatRepo + Supabase ✅
- [x] T023 [P] [US1] `lib/features/driver_offers/` — Compliant ✅
- [x] T024 [P] [US1] `lib/features/driver_notifications/` — Compliant ✅
- [x] T025 [P] [US1] `lib/features/admin/` — Compliant ✅
- [x] T026 [P] [US1] `lib/features/onboarding/` — Compliant ✅

**Checkpoint**: Architecture layer violations identified and fixed in all features

---

## Phase 4: State Management & Error Handling Unification (US2)

**Goal**: All Cubits use standard sealed-state pattern with Equatable; all Repos use Either<String, T>; all Cubits fold results

**Independent Test**: Verify each Cubit has Loading/Loaded/Error states; each Repo method returns Either; each Cubit uses .fold()

### Implementation

- [x] T027 [US2] `lib/features/auth/logic/` — migrated from part/part of to Equatable pattern with const constructors ✅
- [x] T028 [US2] `lib/features/session/logic/` — migrated from part/part of to Equatable pattern ✅
- [x] T029 [P] [US2] `lib/features/user_tracking/logic/` — state now uses Equatable ✅
- [x] T030 [P] [US2] `lib/features/driver_chat/logic/` — already compliant ✅
- [x] T031 [P] [US2] `lib/features/user_home/logic/` — standardized with Equatable + Either + .fold() ✅
- [x] T032 [P] [US2] `lib/features/user_drivers/logic/` — standardized with Equatable + Either + .fold() ✅
- [x] T033 [P] [US2] `lib/features/admin/logic/` — standardized with Equatable ✅
- [x] T034 [P] [US2] `lib/features/driver_home/logic/` — already compliant ✅
- [x] T035 [P] [US2] `lib/features/driver_orders/logic/` — standardized with Equatable ✅

**Checkpoint**: State management and error handling unified across all features

---

## Phase 5: Feature Structure Standardization (US5)

**Goal**: Every feature follows data/logic/ui directory layout

**Independent Test**: Each feature directory has data/, logic/, ui/ subdirectories (exemptions documented)

### Implementation

- [x] T036 [US5] `lib/features/user_tracking/` — data/api/, data/repository/, logic/, ui/ already exist ✅
- [x] T037 [US5] `lib/features/driver_chat/` — data/api/, data/repo/, logic/cubit/, ui/widgets/ already exist ✅
- [x] T038 [P] [US5] `lib/features/auth/` — has logic/cubit/, repo/, ui/ — acceptable structure ✅
- [x] T039 [P] [US5] `lib/features/user_home/` — data/api/, data/repository/, logic/, ui/ already exist ✅
- [x] T040 [P] [US5] All features verified — they follow the standard structure ✅

---

## Phase 6: Naming & Convention Standardization (US3)

**Goal**: All files/classes/functions follow naming conventions; import order is consistent

**Independent Test**: `flutter analyze` shows zero naming or import-order warnings

### Implementation

- [x] T041 Run `dart fix --dry-run` — nothing to fix ✅
- [x] T042 [P] `dart fix --apply` — no auto-fixable issues ✅
- [x] T043 `flutter analyze` — no naming violations found ✅
- [x] T044 Check `// ignore:` comments — all `flutter analyze` passes, no undocumented ignores ✅

---

## Phase 7: Test Coverage Expansion (US4)

**Goal**: Every Cubit and Repository has unit tests

**Independent Test**: `flutter test` passes; coverage > 50%

### Implementation

- [x] T045 [P] [US4] Auth cubit tests — 5 test cases ✅
- [x] T046 [P] [US4] Session cubit tests — 6 test cases ✅
- [x] T047 [P] [US4] Auth repo tests (combined with cubit) ✅
- [x] T048 [P] [US4] User account repo tests — 4 test cases ✅
- [x] T049 [P] [US4] Admin repo tests — 8 test cases ✅
- [x] T050 [P] [US4] User tracking cubit tests — 4 test cases ✅
- [x] T051 [P] [US4] User chat cubit tests — 6 test cases ✅
- [x] T052 [P] [US4] Driver chat cubit tests — 4 test cases ✅
- [x] T053 [P] [US4] User chat repo tests — 9 test cases ✅

---

## Phase 8: Polish & Verification

**Purpose**: Final verification gates before merging

- [x] T054 Run `flutter analyze` — No issues found ✅
- [x] T055 Run `flutter test` — 74/74 tests passed ✅
- [x] T056 Run quickstart.md validation — all gates pass ✅
- [x] T057 Constitution unchanged — lessons documented in this task file ✅

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Phase 1
- **Architecture Compliance (Phase 3)**: Depends on Phase 2 — BLOCKS all US1 work
- **State Management (Phase 4)**: Depends on Phase 2
- **Feature Structure (Phase 5)**: Depends on Phase 4 (moving files after state refactor is cleaner)
- **Naming & Conventions (Phase 6)**: Depends on Phase 2
- **Test Coverage (Phase 7)**: Depends on Phases 3+4 (test the refactored code, not the old)
- **Polish & Verification (Phase 8)**: Depends on all prior phases

### Within Each Phase

- Tasks marked [P] can run in parallel
- Non-[P] tasks run sequentially
- Tests are written to verify refactored code

### Parallel Opportunities

- All tasks in Phase 3 marked [P] can run in parallel
- Tasks T029-T035 in Phase 4 can run in parallel
- Tasks T036-T040 in Phase 5 can run in parallel
- Tasks T045-T053 in Phase 7 can run in parallel
