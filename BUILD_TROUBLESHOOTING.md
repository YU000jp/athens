# Build Troubleshooting Guide

## Network Access Issues in CI/CD

The Athens build process requires access to:
- `repo.clojars.org` - Clojure package repository
- `clojars.org` - Alternative Clojure repository
- `repo1.maven.org` - Maven Central (✅ accessible)

### Current Status
✅ Maven Central is accessible  
❌ Clojars repositories are blocked (DNS REFUSED)

### Clojars Dependencies in deps.edn
The following dependencies require Clojars access:
- `metosin/muuntaja`
- `metosin/reitit`
- `metosin/komponentit` 
- `denistakeda/posh`
- `datascript-transit/datascript-transit`
- And others...

### Solutions

#### 1. For GitHub Actions
- **Enable network access** to clojars.org in repository settings
- **Use dependency caching** (already implemented in clojure-env action)
- **Pre-populate caches** in a separate job with broader network access

#### 2. For local builds
- Ensure internet access to clojars.org
- Dependencies will be cached in ~/.m2/repository after first successful build

#### 3. Alternative approaches
- Pre-download dependencies or use alternative repositories
- Use a dependency proxy or mirror service
- Consider containerized builds with pre-cached dependencies

### Changes Made
- ✅ Removed unused `day8.re-frame/test` dependency
- ✅ Updated GitHub Actions to use newer versions (checkout@v4, cache@v3, etc.)
- ✅ Updated Clojure CLI version in setup-clojure action
- ✅ Added retry logic for dependency fetching
- ✅ Added network connectivity diagnostics

### Verification Steps
To test if the build works after network access is restored:

```bash
# Test dependency resolution
clojure -P

# Test full build process
yarn components
yarn prod

# Test specific build components
npx shadow-cljs compile app
```