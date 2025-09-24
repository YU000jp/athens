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

1. **For GitHub Actions**: Add network access configuration or use GitHub's dependency caching
2. **For local builds**: Ensure internet access to clojars.org
3. **Alternative**: Pre-download dependencies or use alternative repositories

### Changes Made
- Removed unused `day8.re-frame/test` dependency
- Updated GitHub Actions to use newer versions (checkout@v4, cache@v3, etc.)
- Updated Clojure CLI version in setup-clojure action