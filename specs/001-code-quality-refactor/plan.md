# Implementation Plan: Codebase Quality Refactoring

**Branch**: `refactor/code-quality-unification` | **Date**: 2026-06-27 | **Spec**: specs/001-code-quality-refactor/spec.md

**Input**: Full codebase quality improvement - unify patterns, improve testability and maintainability

## Summary

Refactor the entire Live Order Flutter codebase to enforce Clean Architecture layering, unify BLoC/Cubit state management patterns, standardize error handling with dartz Either, fix all naming/lint violations, expand test coverage, and ensure every feature follows the standard directory layout defined in the constitution.

## Technical Context

**Language/Version**: Dart 3.12+, Flutter 3.12.0+

**Primary Dependencies**: flutter_bloc 9.1.1, equatable 2.0.8, dartz 0.10.1, get_it 9.2.1, flutter_lints 6.0.0

**Storage**: Supabase (Postgres) via supabase_flutter 2.8.3, FCM for push

**Testing**: flutter_test (built-in), no mockito/mocktail — use manual mocks or verify with real Supabase in test env

**Target Platform**: iOS, Android, Web

**Project Type**: Mobile app (Flutter) with Clean Architecture + BLoC

**Performance Goals**: N/A (refactoring only — no performance targets)

**Constraints**: `flutter analyze` must pass with zero issues; all existing functionality must remain unchanged

**Scale/Scope**: 17+ feature modules, ~100+ Dart files, 2 core models, shared widgets

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

All gates determined from `.specify/memory/constitution.md` (v1.0.0):

| Gate | Principle | Check |
|------|-----------|-------|
| G1 | I. Clean Architecture & Layering | Every feature must have clear UI → Logic → Data separation. No layer bypassing. |
| G2 | II. BLoC/Cubit State Management | All Cubits must emit immutable states via sealed classes with Loading/Loaded/Error. |
| G3 | III. Repository Pattern & Error Handling | All repos return Either<String, T>. Cubits fold results. |
| G4 | IV. Test-Driven Development | Tests written for models, cubits, and repos. flutter analyze = 0 issues. |
| G5 | V. Dart Conventions & Code Quality | Naming, imports, null safety, deprecations, logging all standardized. |
| G6 | DI & Setup | All deps registered in GetIt with correct order and scope. |
| G7 | Feature Modularity | All features follow data/logic/ui structure. No cross-feature imports. |

## Project Structure

### Documentation (this feature)

```text
specs/001-code-quality-refactor/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 — codebase audit findings
├── quickstart.md        # Validation scenarios
└── tasks.md             # Phase 2 — task breakdown
```

### Source Code (repository root)

```text
lib/
├── core/                # Shared layer — no changes needed structurally
├── features/            # All feature modules — refactoring targets
│   ├── auth/            # Refactor: state pattern, error handling
│   ├── session/         # Refactor: state pattern
│   ├── user_home/       # Verify compliance
│   ├── user_create_shipment/  # Verify compliance
│   ├── user_drivers/    # Refactor: state pattern
│   ├── user_chat/       # Refactor: state pattern, error handling
│   ├── user_tracking/   # Refactor: state pattern
│   ├── user_account/    # Refactor: state pattern
│   ├── user_payments/   # Verify compliance
│   ├── user_rewards/    # Refactor: state pattern
│   ├── user_notifications/ # Refactor: error handling
│   ├── user_rate_driver/   # Verify compliance
│   ├── driver_home/     # Refactor: state pattern
│   ├── driver_orders/   # Verify compliance
│   ├── driver_chat/     # Refactor: error handling
│   ├── driver_offers/   # Verify compliance
│   ├── driver_notifications/ # Verify compliance
│   ├── admin/           # Refactor: state pattern, error handling
│   └── onboarding/      # Verify compliance
├── shared/widgets/      # Shared UI components
└── main_production.dart  # Entry point — verify DI registration

test/                    # Test coverage target
├── core/models/         # Existing tests (keep)
└── features/            # New tests per feature
```

## Complexity Tracking

> No constitution violations expected — this refactoring enforces the constitution.
> Any violation discovered during refactoring will be documented here.
