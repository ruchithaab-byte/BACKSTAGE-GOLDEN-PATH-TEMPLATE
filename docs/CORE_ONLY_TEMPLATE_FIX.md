# Core-Only Template Fix Summary

## Changes Made

### 1. Fixed `catalog-info.yaml`
- Removed complex `parseRepoUrl` filter (not standard in Backstage)
- Simplified repo URL parsing to use standard string replacement
- Added proper defaults for optional fields
- Ensured `name` is lowercase and DNS-safe

### 2. Removed All Module Skeletons
- Deleted entire `modules/` directory from skeleton
- Removed module migration templates
- Template now generates **core-only** monorepo

### 3. Fixed Application Class
- Changed from `{{ values.platformName | replace("-", "") | capitalize }}Application` to concrete `PlatformApplication`
- Prevents placeholder leakage in generated code

## What This Means

✅ **Template is now core-only by default**
- No module checkboxes needed (they're still in UI but won't generate anything)
- Only core kernel (auth, tenant, audit, events) is scaffolded
- Clean, production-ready baseline

## For the Generated Repo (`hims-platform-core`)

You still need to manually fix:

1. **`catalog-info.yaml`** - Replace with:
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: hims-platform-core
  description: HIMS Platform Monorepo
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
```

2. **Delete placeholder files**:
```bash
rm -rf backend-monolith/src/main/java/com/hims/modules
rm -rf backend-monolith/src/main/java/com/hims/{{*
```

3. **Verify no placeholders remain**:
```bash
rg "{{ values" .
```

## Next Steps

1. Fix `catalog-info.yaml` in `hims-platform-core` repo
2. Clean up placeholder files
3. Re-run Backstage registration
4. Future template runs will be clean


## Changes Made

### 1. Fixed `catalog-info.yaml`
- Removed complex `parseRepoUrl` filter (not standard in Backstage)
- Simplified repo URL parsing to use standard string replacement
- Added proper defaults for optional fields
- Ensured `name` is lowercase and DNS-safe

### 2. Removed All Module Skeletons
- Deleted entire `modules/` directory from skeleton
- Removed module migration templates
- Template now generates **core-only** monorepo

### 3. Fixed Application Class
- Changed from `{{ values.platformName | replace("-", "") | capitalize }}Application` to concrete `PlatformApplication`
- Prevents placeholder leakage in generated code

## What This Means

✅ **Template is now core-only by default**
- No module checkboxes needed (they're still in UI but won't generate anything)
- Only core kernel (auth, tenant, audit, events) is scaffolded
- Clean, production-ready baseline

## For the Generated Repo (`hims-platform-core`)

You still need to manually fix:

1. **`catalog-info.yaml`** - Replace with:
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: hims-platform-core
  description: HIMS Platform Monorepo
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
```

2. **Delete placeholder files**:
```bash
rm -rf backend-monolith/src/main/java/com/hims/modules
rm -rf backend-monolith/src/main/java/com/hims/{{*
```

3. **Verify no placeholders remain**:
```bash
rg "{{ values" .
```

## Next Steps

1. Fix `catalog-info.yaml` in `hims-platform-core` repo
2. Clean up placeholder files
3. Re-run Backstage registration
4. Future template runs will be clean

