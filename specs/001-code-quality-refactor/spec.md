# Feature Specification: Codebase Quality Refactoring

**Feature Branch**: `refactor/code-quality-unification`

**Created**: 2026-06-27

**Status**: Draft

**Input**: Full codebase quality improvement - unify patterns, improve testability and maintainability

## User Scenarios & Testing *(mandatory)*

### Developer Story 1 - Consistent Architecture Compliance (Priority: P1)

As a developer maintaining the codebase, I want all features to follow the same Clean Architecture + BLoC patterns so that onboarding new team members is faster and bugs are easier to trace.

**Why this priority**: Architecture violations are the root cause of most maintenance overhead. Fixing layer boundaries first prevents cascading issues in subsequent refactoring.

**Independent Test**: A linter/analyzer check can verify that no Cubit directly imports from API layer, and no UI file imports from data layer. Each feature's imports must pass a dependency rule check.

**Acceptance Scenarios**:

1. **Given** any feature directory, **When** checking the import graph, **Then** UI files only import from logic layer, logic files only import from data layer API/repository and core layer.
2. **Given** any feature, **When** inspecting its Cubit, **Then** the Cubit receives its repository via constructor injection from GetIt and never calls API directly.
3. **Given** the codebase, **When** running `flutter analyze`, **Then** zero warnings or errors are reported.

---

### Developer Story 2 - Unified State Management & Error Handling (Priority: P1)

As a developer, I want all Cubits to follow the same pattern (sealed states with distinct Loading/Loaded/Error subclasses) and all repositories to handle errors consistently using Either<String, T> so that error flows are predictable and testable.

**Why this priority**: Two different patterns (part/part of sealed states vs separate Equatable classes, and dartz Either vs raw try/catch) create cognitive overhead and increase the chance of unhandled error states.

**Independent Test**: Automated checks can verify that every Cubit uses a consistent state pattern and every Repository method returns `Either<String, T>`.

**Acceptance Scenarios**:

1. **Given** any Cubit, **When** examining its state class(es), **Then** it follows the standard pattern: abstract Equatable base class with `const` constructors and Loading/Loaded/Error subclasses.
2. **Given** any Repository, **When** inspecting its method signatures, **Then** all public data-access methods return `Future<Either<String, T>>`.
3. **Given** any Cubit that calls a repository method, **When** processing the result, **Then** it MUST use `.fold()` to handle both Left (error) and Right (success) cases.

---

### Developer Story 3 - Naming & Convention Standardization (Priority: P2)

As a developer, I want file names, class names, import order, and code formatting to be uniform across the entire project so that I can navigate the codebase without context-switching on style.

**Why this priority**: Inconsistent naming slows down navigation and code review. This is mechanical work that can be partially automated.

**Independent Test**: A manual review pass of 10 randomly selected feature directories against the naming convention rules.

**Acceptance Scenarios**:

1. **Given** any Dart file, **When** checking its name and contents, **Then** it follows `snake_case` for files, `PascalCase` for types, `camelCase` for functions/variables.
2. **Given** any Dart file, **When** inspecting its imports, **Then** they are grouped as `dart:` → `package:` → `package:live_order/` with blank-line separators.

---

### Developer Story 4 - Test Coverage Expansion (Priority: P2)

As a quality assurance engineer, I want unit tests for all Cubits and Repositories so that regressions are caught automatically before deployment.

**Why this priority**: Currently only model tests exist. Cubits and repositories have zero test coverage.

**Independent Test**: `flutter test` reports > 50% line coverage for the refactored features.

**Acceptance Scenarios**:

1. **Given** the entire codebase, **When** running `flutter test`, **Then** all tests pass with zero failures.
2. **Given** any Cubit under test, **When** its repository dependency is mocked, **Then** each state transition (Initial → Loading → Loaded/Error) is tested in isolation.

---

### Developer Story 5 - Consistent Feature Structure (Priority: P3)

As a developer, I want every feature to follow the same data/api → data/repository → logic/cubit → ui/screen directory layout so that I can find files by convention.

**Why this priority**: Older features use flat structures or different conventions. This is consolidation work with low risk.

**Independent Test**: A directory listing script verifies each feature has the expected subdirectory structure.

**Acceptance Scenarios**:

1. **Given** any feature in `lib/features/`, **When** listing its subdirectories, **Then** it contains `data/`, `logic/`, and `ui/` (or is explicitly exempted in a whitelist).
2. **Given** a feature's `data/` directory, **When** inspecting it, **Then** it contains `api/` and `repository/` subdirectories (models/ subdirectory is optional).

---

### Edge Cases

- What happens when a feature has only 1-2 files (e.g., very simple screens)? These may be exempted from the full directory structure but MUST document the exemption.
- What happens when old test files reference old file paths? Tests must be updated as part of the refactoring.
- What happens if renaming a file breaks multiple imports? A coordinated rename must be done with `git mv` and all import paths updated atomically.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All Cubit states MUST use a consistent pattern: abstract sealed class extending Equatable with Loading/Loaded/Error subclasses.
- **FR-002**: All Repository public methods MUST return `Future<Either<String, T>>`.
- **FR-003**: All Cubits MUST use `.fold()` on `Either` results to handle success and error states.
- **FR-004**: No Cubit or UI file MAY directly import from an API class — all API access goes through a Repository.
- **FR-005**: No UI file MAY import from the data layer — UI only imports from the logic layer.
- **FR-006**: All features MUST follow the `data/` → `logic/` → `ui/` directory structure.
- **FR-007**: All file names MUST be `snake_case`. All class names MUST be `PascalCase`. All functions/variables MUST be `camelCase`.
- **FR-008**: All `dart:` imports MUST come first, then `package:` (third-party), then `package:live_order/` (project), separated by blank lines.
- **FR-009**: Every Cubit MUST have unit tests covering its Loading, Loaded, Error, and initial states.
- **FR-010**: Every Repository method MUST have a unit test covering the success path and the error path.
- **FR-011**: All dependencies MUST be injected via constructor parameters from GetIt — no direct `GetIt` calls inside constructors.
- **FR-012**: All `AppLogger` calls MUST use the correct tag format (feature name) and MUST be guarded by `kDebugMode`.

### Key Entities *(include if feature involves data)*

- **Feature Module**: A self-contained directory under `lib/features/` following the Clean Architecture structure with data/logic/ui layers.
- **Cubit**: State management class following BLoC pattern with sealed state classes.
- **Repository**: Data orchestration class that translates between API responses and domain models.
- **Either<String, T>**: Functional error handling type from `dartz` — Left carries error string, Right carries success data.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `flutter analyze` reports zero warnings and zero errors across the entire project.
- **SC-002**: All 15+ feature directories follow the standard `data/logic/ui` structure.
- **SC-003**: 100% of Cubits use the same sealed-state pattern with Loading/Loaded/Error subclasses.
- **SC-004**: 100% of Repositories return `Either<String, T>` from their public methods.
- **SC-005**: `flutter test` passes with > 50% line coverage (up from < 5%).
- **SC-006**: Import ordering is consistent across 100% of Dart files.
- **SC-007**: No file or class has a naming convention violation.

## Assumptions

- The existing `dartz` library will be used for `Either` — no need to introduce a new error handling library.
- `flutter_lints` package is already configured and will catch most convention violations.
- The `AppLogger` utility class in `core/utils/logger.dart` will be used for all logging.
- The `equatable` package is available for state equality comparisons.
- `GetIt` DI container is already set up in `core/di/di.dart` with the correct initialization order.
- Renaming files is safe with `git mv` — import paths will be updated to match.
- Some older features (onboarding, auth) may use different patterns — these will be migrated to the standard.
