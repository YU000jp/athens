#!/bin/bash
# Dependency pre-cache script for Athens
# This script attempts to download dependencies when full network access is available

set -e

echo "🔄 Pre-caching Athens dependencies..."
echo "This script downloads dependencies to ~/.m2/repository for offline use"
echo ""

# Check if we can access Clojars
if curl -s --connect-timeout 5 --max-time 10 https://repo.clojars.org/ > /dev/null; then
    echo "✅ Clojars accessible - downloading all dependencies..."
    clojure -P
    echo "✅ All dependencies cached successfully"
else
    echo "❌ Clojars not accessible"
    echo "Attempting to cache Maven Central dependencies only..."
    
    # Try to cache what we can from Maven Central
    if curl -s --connect-timeout 5 --max-time 10 https://repo1.maven.org/maven2/ > /dev/null; then
        echo "✅ Maven Central accessible"
        # This will cache dependencies that are available on Maven Central
        clojure -P 2>/dev/null || echo "⚠️  Some dependencies could not be resolved"
    else
        echo "❌ No repositories accessible - dependencies cannot be pre-cached"
        exit 1
    fi
fi

echo ""
echo "📊 Cached dependency summary:"
echo "Dependencies are cached in: ~/.m2/repository"
if [ -d ~/.m2/repository ]; then
    du -sh ~/.m2/repository 2>/dev/null || echo "Cache directory exists but size unknown"
else
    echo "No cache directory created"
fi