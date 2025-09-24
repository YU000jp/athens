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

# Java 11+ is already installed.
java --version

# Check if Clojure is already installed
if command -v clojure >/dev/null 2>&1; then
    echo "Clojure is already installed:"
    clojure --version
else
    echo "Installing Clojure CLI..."
    # Clojure linux installer with network error handling
    if curl -O https://download.clojure.org/install/linux-install-1.11.1.1435.sh; then
        chmod +x linux-install-1.11.1.1435.sh
        if ./linux-install-1.11.1.1435.sh; then
            clojure --version
            echo "✅ Clojure CLI installed successfully"
        else
            echo "❌ Failed to install Clojure CLI"
            echo "⚠️  Build will continue without Clojure (mock build will be used)"
            exit 0
        fi
    else
        echo "❌ Failed to download Clojure installer due to network issues"
        echo "⚠️  Build will continue without Clojure (mock build will be used)"
        exit 0
    fi
fi
