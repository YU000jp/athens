#!/usr/bin/env bash

# Fail on all sorts of errors, but allow graceful handling of network issues
# https://stackoverflow.com/a/2871034/2116927
set -euo pipefail

# In Vercel -> Project Settings -> Build & Development Settings:
# Build command   : yarn vercel:build
# Output directory: vercel-static
# Install command : yarn vercel:install
#
# In Vercel -> Project Settings -> Git
# Release branch: dummy-vercel-web
# Pre-release branch: dummy-vercel-beta
# These are dummy branches that we do not push builds to.
# Instead the `release-web` github actions job manually builds and deploys a prod build when needed.
# The build settings above are still used for the prod build though, and the
# vercel-release/package.json file is meant to provide noop scripts for it.

# See https://vercel.com/docs/concepts/deployments/build-step#build-image for custom setup instructions.

echo "🔧 Athens Vercel Setup"
echo "====================="

# Java 11+ is already installed.
echo "☕ Java version:"
java --version

# Check if we can access external repositories
echo ""
echo "🌐 Testing network connectivity..."
if curl -s --connect-timeout 5 --max-time 10 https://repo1.maven.org/maven2/ > /dev/null; then
    echo "✅ Maven Central accessible"
    MAVEN_ACCESSIBLE=true
else
    echo "❌ Maven Central not accessible"
    MAVEN_ACCESSIBLE=false
fi

if curl -s --connect-timeout 5 --max-time 10 https://repo.clojars.org/ > /dev/null; then
    echo "✅ Clojars accessible"
    CLOJARS_ACCESSIBLE=true
else
    echo "❌ Clojars not accessible"
    CLOJARS_ACCESSIBLE=false
fi

echo ""

# Check if Clojure is already installed
if command -v clojure >/dev/null 2>&1; then
    echo "✅ Clojure is already installed:"
    clojure --version
    CLOJURE_AVAILABLE=true
else
    echo "🔄 Installing Clojure CLI..."
    # Try to install Clojure CLI with timeout and error handling
    if timeout 60s curl -O https://download.clojure.org/install/linux-install-1.11.1.1435.sh 2>/dev/null; then
        chmod +x linux-install-1.11.1.1435.sh
        if timeout 120s ./linux-install-1.11.1.1435.sh 2>/dev/null; then
            clojure --version
            echo "✅ Clojure CLI installed successfully"
            CLOJURE_AVAILABLE=true
        else
            echo "❌ Failed to install Clojure CLI"
            CLOJURE_AVAILABLE=false
        fi
    else
        echo "❌ Failed to download Clojure installer (network timeout or blocked)"
        CLOJURE_AVAILABLE=false
    fi
fi

echo ""

# Determine build strategy based on available tools
if [ "$CLOJURE_AVAILABLE" = true ] && [ "$CLOJARS_ACCESSIBLE" = true ]; then
    echo "🎯 Full build mode: Clojure and dependencies available"
    export ATHENS_BUILD_MODE="full"
elif [ "$CLOJURE_AVAILABLE" = true ] && [ "$MAVEN_ACCESSIBLE" = true ]; then
    echo "⚠️  Partial build mode: Clojure available but some dependencies may fail"
    echo "    Will attempt full build with fallback to components-only build"
    export ATHENS_BUILD_MODE="partial"
else
    echo "🧪 Mock build mode: Limited network access or missing Clojure"
    echo "    Will use pre-compiled components and static fallback"
    export ATHENS_BUILD_MODE="mock"
fi

echo "Build mode: $ATHENS_BUILD_MODE"
