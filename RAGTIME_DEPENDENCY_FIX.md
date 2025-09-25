# Ragtime Dependency Issue - Resolution Documentation

## Issue Description

The Athens project was encountering a build error:
```
Error building classpath. Could not find artifact ragtime:ragtime.jdbc:jar:0.8.1 in central (https://repo1.maven.org/maven2/)
```

## Root Cause Analysis

1. **Missing Dependency**: `ragtime:ragtime.jdbc:jar:0.8.1` was specified in `deps.edn` but this version does not exist in Maven Central
2. **Unused Dependency**: Investigation revealed that ragtime is not actually used in the Athens codebase
3. **Custom Migration System**: Athens uses its own custom migration system (`athens.common.migrations`) for Fluree database migrations, not SQL migrations that ragtime provides

## Solution Implemented

### 1. Removed Unused Ragtime Dependencies

**File**: `deps.edn` and `deps-no-clojars.edn`

**Before**:
```clojure
;; Database migrations (if needed)
ragtime/ragtime.jdbc                  #:mvn{:version "0.8.1"}
ragtime/ragtime.core                  #:mvn{:version "0.8.1"}
```

**After**:
```clojure
;; Database migrations handled by custom system in athens.common.migrations
;; ragtime/ragtime.jdbc                  #:mvn{:version "0.8.1"}
;; ragtime/ragtime.core                  #:mvn{:version "0.8.1"}
```

### 2. Re-enabled Clojars Repository Access

Since some essential Athens dependencies are only available on Clojars, we restored Clojars access:

**Before**:
```clojure
;; Clojars commented out for restricted environments
;; Uncomment if access becomes available
;;"clojars"   {:url "https://repo.clojars.org/"}
```

**After**:
```clojure
;; Clojars included as fallback for libraries like tick that are not on Maven Central
"clojars"   {:url "https://repo.clojars.org/"}
```

### 3. Restored Essential Clojars-Only Dependencies

The following dependencies were uncommented as they are required by the application:

- **tick/tick**: Required for date functionality in `athens.dates`
- **denistakeda/posh**: Required for DataScript integration in `athens.reactive`
- **metosin/reitit**: Required for routing functionality in `athens.router`
- **metosin/komponentit**: UI component utilities

### 4. Fixed JavaScript Dependencies

**Issue**: react-error-boundary v6.0.0 was incompatible with shadow-cljs due to ES module format

**Solution**: Downgraded to react-error-boundary v4.1.2 which uses CommonJS format compatible with shadow-cljs

## Why These Dependencies Are Necessary

### Athens Migration System

Athens uses a custom migration system specifically designed for Fluree (graph database):

- **File**: `src/cljc/athens/common/migrations.cljc`
- **Purpose**: Handles schema and data migrations for Fluree database
- **Features**: Interruptible, resumable, idempotent migrations

This custom system is **not** compatible with ragtime, which is designed for SQL databases.

### Essential Clojars Dependencies

| Dependency | Purpose | Alternative on Maven Central? |
|------------|---------|------------------------------|
| tick/tick | Date/time operations | ❌ Not available |
| denistakeda/posh | DataScript-Reagent integration | ❌ Not available |
| metosin/reitit | Frontend routing | ❌ Not available |
| metosin/komponentit | UI component utilities | ❌ Not available |

## Build Verification

After applying the fix:

1. ✅ Dependencies resolve successfully: `clojure -P`
2. ✅ JavaScript components build: `yarn components`
3. ✅ ClojureScript compilation succeeds: `clojure -A:shadow-cljs compile app`
4. ✅ Production build works: `yarn prod`

**Final artifact size**: 28.9MB compiled JavaScript (app.js)

## Impact on Deployment Environments

### Environments with Clojars Access
- ✅ Full functionality available
- ✅ All features work as expected

### Restricted Environments (No Clojars)
- ❌ Build will fail due to missing essential dependencies
- 🔧 **Workaround**: Use dependency caching/mirroring for essential Clojars packages

## Repository Priority Configuration

The current configuration prioritizes Maven Central while keeping Clojars as fallback:

```clojure
:mvn/repos
{"central"   {:url "https://repo1.maven.org/maven2/"}          ; Highest priority
 "sonatype"  {:url "https://oss.sonatype.org/content/repositories/public/"}
 "maven2"    {:url "https://repo.maven.apache.org/maven2/"}
 "jcenter"   {:url "https://jcenter.bintray.com/"}
 "clojars"   {:url "https://repo.clojars.org/"}}              ; Fallback for essential deps
```

This ensures maximum compatibility while minimizing dependency on Clojars where possible.