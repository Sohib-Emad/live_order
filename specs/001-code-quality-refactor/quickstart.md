# Quickstart: Codebase Quality Refactoring Validation

## Prerequisites

- Flutter SDK 3.12.0+
- Dart 3.12+

## Validation Commands

### 1. Lint Gate

```bash
flutter analyze
```
**Expected**: 0 issues, 0 warnings, 0 errors

### 2. Test Gate

```bash
flutter test
```
**Expected**: All tests pass. Coverage > 50% (line coverage)

### 3. Build Gate

```bash
flutter build apk --debug --no-shrink
# or for iOS:
flutter build ios --debug --no-codesign
```
**Expected**: Build succeeds with no errors

### 4. Import Check (Manual)

```bash
# Check that no UI file imports from data layer
grep -r "import.*data/" lib/features/*/ui/ --include="*.dart" | grep -v "data/models" || echo "No direct data layer imports from UI ✅"
```

**Expected**: No UI file imports data layer files (except data/models for type references)

### 5. State Pattern Check (Manual)

For each feature, verify the logic/ directory contains:
- `cubit.dart` — Cubit class
- `state.dart` — Abstract Equatable base + Loading/Loaded/Error subclasses

### 6. Feature Structure Check

```bash
for f in lib/features/*/; do
  name=$(basename "$f")
  echo "Feature: $name"
  echo "  data: $(ls -d "$f"data/" 2>/dev/null && echo ✅ || echo ❌)"
  echo "  logic: $(ls -d "$f"logic/" 2>/dev/null && echo ✅ || echo ❌)"
  echo "  ui: $(ls -d "$f"ui/" 2>/dev/null && echo ✅ || echo ❌)"
done
```

**Expected**: Every feature has data/, logic/, and ui/ directories.
