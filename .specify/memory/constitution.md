<!--
  Sync Impact Report
  Version change: (new) → 1.0.0
  Modified principles: All new (initial creation)
  Added sections: All (initial creation)
  Removed sections: None
  Templates requiring updates:
    - .specify/templates/plan-template.md: ✅ Updated (Constitution Check section already references)
    - .specify/templates/spec-template.md: ✅ No changes needed
    - .specify/templates/tasks-template.md: ✅ No changes needed
    - .specify/templates/checklist-template.md: ✅ No changes needed
  Follow-up TODOs: None
-->
# Live Order Constitution

## Core Principles

### I. Clean Architecture & Layering (NON-NEGOTIABLE)

Each layer MUST have a single, well-defined responsibility:

- **UI Layer** (screens & widgets): Render state and capture user input. MUST NOT
  contain business logic, data transformation, or API calls.
- **Logic Layer** (Cubits): Manage state transitions and orchestrate repository
  calls. MUST NOT directly call API or database operations.
- **Data Layer** (Repositories + APIs): Handle all data access. Repositories
  translate between API responses and domain models; API classes perform raw
  Supabase/Firebase operations.

Dependencies MUST point inward: UI → Logic → Data. No layer MAY bypass another.

### II. BLoC/Cubit State Management

- Each feature MUST have exactly one Cubit managing its state.
- States MUST be immutable. Use `Equatable` for value equality or sealed classes
  with distinct state subclasses (`Loading`, `Loaded`, `Error`, etc.).
- The Cubit MUST emit a new state object for every change — never mutate
  existing state.
- UI MUST use `BlocBuilder` / `BlocConsumer` / `BlocListener` to react to
  state changes. `BlocProvider` MUST be provided at the route level via DI.
- State subclasses MUST use `const` constructors where possible.

### III. Repository Pattern & Error Handling

- All data access MUST go through Repository classes — no direct API calls
  from Cubits or UI.
- Repositories MUST return `Either<String, T>` (via `dartz`) for predictable,
  typed error handling. `Left` carries a user-facing error message; `Right`
  carries success data.
- API classes MUST be stateless singletons. They perform only raw
  Supabase/Firebase operations and throw exceptions on failure.
- Cubits MUST fold over `Either` results: `result.fold((error) => emit(Error), (data) => emit(Loaded(data)))`.
- Stream-based data (realtime subscriptions) MUST be managed through dedicated
  repository methods, never directly in Cubits.

### IV. Test-Driven Development

- **Models**: Every model MUST have unit tests covering `fromJson`, `toJson`,
  `copyWith`, field defaults, null handling, round-trip serialization, and
  edge cases (empty strings, missing keys, legacy key fallbacks).
- **Cubits**: MUST be testable via constructor-injected repository mocks.
  Write unit tests for each state transition (loading, success, error).
- **Repositories**: Integration tests SHOULD verify real API contract behaviour.
  Use the Supabase client directly in a test environment.
- `flutter analyze` MUST pass with zero issues before any commit.
- Tests MUST be run with `flutter test` and MUST pass before merging.

### V. Dart Conventions & Code Quality

- **Naming**: `PascalCase` for types, `camelCase` for variables/functions/methods,
  `snake_case` for file names, `ALL_CAPS` for constants.
- **Imports**: Grouped in order — `dart:` → `package:` → `package:live_order/`,
  with blank-line separators between groups.
- **Null Safety**: Use `?` for nullable types, `late` only when initialization
  is guaranteed before access. Avoid `!` null-assertions unless proven safe.
- **Warnings**: Treat all linter warnings as errors. Use `// ignore:` only with
  a documented reason.
- **Deprecations**: Deprecated APIs MUST be migrated promptly (e.g.,
  `.withOpacity()` → `.withValues(alpha:)`).
- **Logging**: Use `AppLogger` (guarded behind `kDebugMode`) for all
  non-trivial operations. Never commit `print()` or `debugPrint()` calls.

## Dependency Injection & Setup

### DI Principles

- All dependencies MUST be registered in `lib/core/di/di.dart` via `GetIt`.
- Registration order MUST be: APIs → Repositories → Cubits.
- APIs and Repositories MUST use `registerSingleton()` (stateless, shared).
- Cubits MUST use `registerFactory()` (new instance per route).
- DO NOT use annotations or code generation for DI — manual registration
  keeps the dependency graph explicit and auditable.

### Boot Sequence

```
main() → await Supabase.initialize() → init() [register DI] → runApp()
```

No Cubit or Repository SHOULD call `GetIt` directly in its constructor;
dependencies MUST be injected via constructor parameters.

## Feature Modularity & Project Structure

### Feature Directory Layout

Every feature MUST follow this exact structure:

```
features/{feature_name}/
├── data/
│   ├── api/           # Supabase/Firebase client calls
│   ├── models/        # Feature-specific DTOs (if needed)
│   └── repository/    # Business logic data orchestration
├── logic/
│   ├── cubit.dart     # BLoC/Cubit definition + events (if Bloc)
│   └── state.dart     # State class(es)
└── ui/
    ├── screen.dart    # Main screen
    └── widget/        # Feature-specific widgets
```

### Cross-Cutting Rules

- Features MUST NOT import from other features — only from `core/`.
- Shared widgets belong in `shared/widgets/`, not in a feature.
- Core models (`Shipment`, `UserProfile`) live in `core/models/`.
- No feature MAY define its own version of a core model.

## Governance

- This constitution supersedes all ad-hoc practices.
- **Amendments**: Any change to principles requires a documented proposal,
  team review, and a MAJOR or MINOR version bump.
- **Versioning**:
  - MAJOR: Backward-incompatible governance/principle changes.
  - MINOR: New principle added or materially expanded.
  - PATCH: Clarifications, wording fixes, non-semantic refinements.
- **Compliance**: Every PR and review MUST verify that new code adheres to
  these principles. Violations MUST be flagged and justified via the
  Complexity Tracking mechanism in `plan-template.md`.
- **Lint Gate**: `flutter analyze` MUST pass before any merge. `flutter test`
  MUST pass before any deployment.

**Version**: 1.0.0 | **Ratified**: 2026-06-27 | **Last Amended**: 2026-06-27
