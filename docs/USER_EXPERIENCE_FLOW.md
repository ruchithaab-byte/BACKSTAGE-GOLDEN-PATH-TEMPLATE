# User Experience Flow - Simple Explanation

## Scenario 1: First Time - Creating Monorepo with Billing Module

### What User Does:
1. Goes to Backstage
2. Clicks "Create HIMS Platform Module"
3. Fills in form:
   - Module Name: `billing`
   - Module Pattern: `billing` (from dropdown)
   - Include PM-JAY: ✅ Yes
   - Include NHCX: ✅ Yes
   - Repository URL: `github.com/myorg/hims-platform` (NEW repo)
4. Clicks "Create"

### What Happens:
1. ✅ **Backstage creates a NEW GitHub repository** (`github.com/myorg/hims-platform`)
2. ✅ **Scaffolds complete monorepo structure**:
   ```
   hims-platform/
   ├── backend-monolith/
   │   └── modules/
   │       └── billing/          ← Billing module created
   ├── frontend/
   ├── analytics-worker/
   └── ...
   ```
3. ✅ **Pushes code to GitHub**
4. ✅ **Registers in Backstage Catalog**

### Result:
- ✅ **New repository created**
- ✅ **Billing module scaffolded**
- ✅ **Ready to use**

---

## Scenario 2: Second Time - Adding Clinical Module

### What User Does:
1. Goes to Backstage again
2. Clicks "Create HIMS Platform Module" (same template)
3. Fills in form:
   - Module Name: `clinical`
   - Module Pattern: `clinical` (from dropdown)
   - FHIR Resource Types: `[Patient, Encounter]`
   - Repository URL: `github.com/myorg/hims-platform` (SAME repo as before)
4. Clicks "Create"

### What Happens (Current Behavior):
❌ **PROBLEM**: Backstage templates are designed for "create new", not "add to existing"

**Current Result:**
- ❌ **Tries to create NEW repository** (fails if repo exists)
- ❌ **OR overwrites existing repo** (loses billing module!)
- ❌ **Does NOT add clinical module to existing repo**

### Why This Happens:
- Backstage `publish:github` action creates new repos
- It doesn't support "add files to existing repo"
- This is a limitation of standard Backstage templates

---

## The Problem

**Backstage templates = "Create New" only**

They can't easily "add to existing" repositories without custom actions.

---

## Solution Options

### Option 1: Two Separate Templates (Recommended for Now)

**Template 1: Create Monorepo** (First Time)
- Creates new repository
- Scaffolds complete monorepo
- Includes initial modules (billing, clinical, etc.)

**Template 2: Add Module** (Later)
- Requires existing repo URL
- Uses custom action to add module to existing repo
- More complex, requires custom development

### Option 2: Single Template with "Mode" Selection

**User selects:**
- Mode: `Create New Monorepo` OR `Add Module to Existing`
- If "Add Module":
  - Requires existing repo URL
  - Uses custom action to clone, add, commit, push
  - More complex implementation

### Option 3: Manual Process (Simplest for Now)

**First Time:**
- Use template to create monorepo with all needed modules
- Select multiple modules in one go (billing ✅, clinical ✅, inventory ✅)

**Later:**
- Manually add new modules to existing repo
- OR use template to scaffold module locally, then copy to repo

---

## Recommended Approach: Single Template, Multiple Modules

### Better User Experience:

**First Time - Create Monorepo with Multiple Modules:**

1. User goes to Backstage
2. Selects "Create HIMS Platform Monorepo"
3. Fills form:
   - Platform Name: `hims-platform`
   - **Initial Modules** (checkboxes):
     - ✅ Include Clinical Module
     - ✅ Include Billing Module
     - ✅ Include Inventory Module
   - Repository URL: `github.com/myorg/hims-platform`
4. Clicks "Create"

**What Happens:**
- ✅ Creates NEW repository
- ✅ Scaffolds complete monorepo
- ✅ Creates ALL selected modules at once:
  ```
  hims-platform/
  ├── backend-monolith/
  │   └── modules/
  │       ├── clinical/      ← Created
  │       ├── billing/       ← Created
  │       └── inventory/     ← Created
  ```

**Result:**
- ✅ All modules created in one go
- ✅ No need to run template multiple times
- ✅ Everything in one repository from start

---

## For Adding Modules Later

### Option A: Manual Addition (Simplest)
1. Developer clones repo locally
2. Uses template to scaffold module (locally or in temp directory)
3. Copies module code to existing repo
4. Commits and pushes

### Option B: Custom Backstage Action (Future)
1. Create custom action: `add-module-to-repo`
2. Action clones existing repo
3. Adds new module files
4. Commits and pushes
5. More complex, requires development

### Option C: Separate "Add Module" Template (Future)
1. Create dedicated template for adding modules
2. Uses custom action to modify existing repo
3. More complex, requires development

---

## Simple Answer to Your Question

### Q: User selects billing first time - what happens?
**A:** Creates NEW monorepo with billing module only.

### Q: User comes again, wants to add clinical - what happens?
**A:** ❌ **Current template CAN'T add to existing repo** - it would try to create a new repo (fails) or overwrite existing one (bad!).

### Q: What if user gives same repo URL?
**A:** ❌ **It will fail** (repo exists) or **overwrite** (loses existing code) - both are bad!

---

## Recommended Solution

### Use Template to Create Monorepo with ALL Modules at Once:

**User Experience:**
1. First time: Select ALL modules you need (billing ✅, clinical ✅, inventory ✅)
2. Template creates monorepo with all modules
3. Done! Everything in one repo from start

**For Adding Modules Later:**
- Manual process (copy from template output)
- OR develop custom action (future work)

---

## Visual Flow

### Current Flow (Problematic):
```
Time 1: Template → Create Repo → billing module
Time 2: Template → ??? → clinical module  ❌ Can't add!
```

### Recommended Flow:
```
Time 1: Template → Create Repo → billing + clinical + inventory (all at once)
Time 2+: Manual addition OR custom action
```

---

## Summary

**Simple Answer:**

1. **First time**: Template creates NEW repo with selected modules
2. **Second time**: Template CAN'T add to existing repo (Backstage limitation)
3. **Solution**: Create all needed modules in first run, or add manually later

**Best Practice**: Select all modules you need when creating the monorepo the first time.

