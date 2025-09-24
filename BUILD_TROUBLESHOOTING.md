# Build Troubleshooting Guide

## Network Access Issues in CI/CD

The Athens build process requires access to:
- `repo.clojars.org` - Clojure package repository (primary source for many dependencies)
- `repo1.maven.org` - Maven Central (✅ accessible) 
- `oss.sonatype.org` - Sonatype public repositories (✅ accessible)

### Current Status
✅ Maven Central is accessible  
✅ Sonatype repositories are accessible
❌ Clojars repositories are blocked (DNS REFUSED)

### Dependencies and Their Sources

The Athens project uses dependencies from multiple sources:

**Available on Maven Central:**
- Core Clojure libraries (`org.clojure/*`)
- Standard Java ecosystem libraries
- Some widely-used Clojure libraries

**Clojars-only dependencies:**
- `metosin/reitit` - HTTP routing library
- `metosin/muuntaja` - Data format transformation
- `metosin/komponentit` - UI component utilities
- `denistakeda/posh` - DataScript integration
- `datascript-transit/datascript-transit` - DataScript serialization
- And others...

### Repository Configuration

Athens now uses a **repository priority configuration** in `deps.edn`:

```clojure
:mvn/repos
{"central"   {:url "https://repo1.maven.org/maven2/"}          ; Highest priority
 "sonatype"  {:url "https://oss.sonatype.org/content/repositories/public/"}
 "clojars"   {:url "https://repo.clojars.org/"}}              ; Fallback when accessible
```

This configuration ensures Maven Central is tried first, reducing dependency on Clojars when possible.

### Solutions

#### 1. For GitHub Actions / CI Environments
- **Enable network access** to clojars.org in repository/organization settings
- **Use dependency caching** with the new pre-cache script
- **Pre-populate caches** in environments with full network access

#### 2. Pre-cache Dependencies (Recommended)
Use the provided script to cache dependencies when network access is available:
```bash
# Pre-download dependencies for offline use
./script/pre-cache-deps.sh

# Later, build with cached dependencies
clojure -P  # Will use cached dependencies
yarn prod   # Normal build process
```

#### 3. For Local Development
- Ensure internet access to clojars.org
- Dependencies will be cached in `~/.m2/repository` after first successful build
- Subsequent builds can work offline using cached dependencies

#### 4. Alternative Approaches

**Mirror Services (Advanced):**
```clojure
;; Example: Using a corporate repository manager
:mvn/repos
{"corporate-mirror" {:url "https://nexus.company.com/repository/maven-public/"}}
```

**Docker-based Development:**
- Use pre-built Docker images with cached dependencies
- Ideal for restricted network environments

### Changes Made
- ✅ Added repository priority configuration in `deps.edn`
- ✅ Created dependency pre-cache script (`script/pre-cache-deps.sh`)
- ✅ Updated documentation with comprehensive solutions
- ✅ Maintained compatibility with existing build process

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

# Pre-cache dependencies for future offline builds
./script/pre-cache-deps.sh
```

### Network Access Diagnostic Commands
```bash
# Test repository accessibility
curl -I https://repo1.maven.org/maven2/        # Should work
curl -I https://repo.clojars.org/               # May be blocked
curl -I https://oss.sonatype.org/content/repositories/public/  # Should work

# Check dependency cache
ls -la ~/.m2/repository/

# Verify Clojure installation
clojure --version
java --version
```