# Research: Codebase Audit Findings

**Phase 0 output for plan.md** | **Feature**: Codebase Quality Refactoring

## Methodology

Manual audit of `lib/features/` and `lib/core/` using the constitution principles as the
checklist. Each feature was inspected for:
- State management pattern (sealed classes vs part/part of vs Equatable)
- Error handling (dartz Either vs try/catch)
- Architecture layering (UI → Logic → Data isolation)
- Naming conventions
- Import ordering
- Feature directory structure

## Feature-by-Feature Findings

### Auth (`lib/features/auth/`)
- **State pattern**: Uses part/part of with AuthState sealed class — MIGRATE to standard Equatable pattern
- **Error handling**: Uses dartz Either in repo ✅ — Cubit uses .fold() ✅
- **Directory structure**: Flat (logic/cubit/, repo/, ui/) — needs restructuring
- **Naming**: Some files use camelCase (auth_cubit.dart → should be snake_case ✅ already)

### Session (`lib/features/session/`)
- **State pattern**: Uses part/part of with HomeState sealed class — MIGRATE
- **Error handling**: Uses dartz Either in repo ✅
- **Structure**: data/api/ + data/repo/ + logic/cubit/ + ui/ — almost standard

### User Home (`lib/features/user_home/`)
- **State pattern**: Uses Cubit with separate state file
- **Error handling**: Uses dartz Either
- **Structure**: data/api/ + data/repo/ + logic/ + ui/ — needs review

### User Tracking (`lib/features/user_tracking/`)
- **State pattern**: TrackingCubit with TrackingState
- **Error handling**: try/catch in Cubit (not Either) — FIX to use Either from repo
- **Structure**: ui/screen + ui/widget/ — needs logic/ and data/ directories

### Driver Chat (`lib/features/driver_chat/`)
- **State pattern**: Uses Cubit with state
- **Error handling**: try/catch — FIX to Either pattern
- **Structure**: ui/widget/ — needs restructuring

### User Chat (`lib/features/user_chat/`)
- **State pattern**: Uses Cubit with separate state
- **Error handling**: dartz Either — good
- **Structure**: data/api/ + data/model/ + data/repository/ + logic/ + ui/ — good

### User Account (`lib/features/user_account/`)
- **State pattern**: Uses Cubit with Equatable states — good
- **Error handling**: dartz Either in repo ✅
- **Structure**: data/ (api, repo) + logic/ + ui/ — good

### Admin (`lib/features/admin/`)
- **State pattern**: Uses Cubit with separate state files
- **Error handling**: dartz Either — good
- **Structure**: needs verification

### Driver Orders (`lib/features/driver_orders/`)
- **Structure**: data/api/ + data/repo/ + logic/ + ui/ — good

### Other features (onboarding, user_payments, user_rewards, user_rate_driver, user_notifications, driver_offers, driver_notifications)
- Require individual inspection

## Cross-Cutting Issues

| Issue | Severity | Affected Features |
|-------|----------|-------------------|
| part/part of pattern not standard | HIGH | auth, session |
| try/catch instead of Either.fold | HIGH | user_tracking cubit, driver_chat cubit |
| Missing data/logic directories | MEDIUM | user_tracking, driver_chat |
| Inconsistent state patterns | MEDIUM | Multiple features |
| No Cubit tests | HIGH | All features |
| No Repository tests | HIGH | All features |
| Naming convention violations | MEDIUM | Need lint check |
| Import order violations | LOW | Need lint check |

## Decisions

- **State pattern**: Use separate state files with abstract Equatable class and const constructors (not part/part of)
- **Error handling**: All repos use Either<String, T>, all cubits use .fold()
- **Directory layout**: Every feature must have data/api/ → data/repository/ → logic/ → ui/ (with optional widget/ and models/)
- **Testing**: Manual mocks (no mocktail dependency needed — inject fake repos)
