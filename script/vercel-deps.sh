#!/usr/bin/env bash

# Handle Clojure dependency installation for Vercel
set -e

echo "📦 Athens Dependency Setup"
echo "=========================="

# Get build mode from vercel-setup.sh
ATHENS_BUILD_MODE=${ATHENS_BUILD_MODE:-"mock"}

case "$ATHENS_BUILD_MODE" in
    "full")
        echo "🎯 Installing Clojure dependencies (full mode)..."
        if timeout 300s clojure -P; then
            echo "✅ All dependencies installed successfully"
        else
            echo "❌ Clojure dependency installation failed or timed out"
            echo "⚠️  Switching to mock build mode"
            export ATHENS_BUILD_MODE="mock"
        fi
        ;;
    "partial")
        echo "⚠️  Attempting Clojure dependencies (partial mode)..."
        if timeout 300s clojure -P; then
            echo "✅ Dependencies installed successfully"
        else
            echo "❌ Some dependencies failed to install"
            echo "⚠️  Will use components-only build"
            export ATHENS_BUILD_MODE="components-only"
        fi
        ;;
    "mock")
        echo "🧪 Skipping Clojure dependencies (mock mode)"
        echo "   Will use pre-compiled components only"
        ;;
    *)
        echo "⚠️  Unknown build mode: $ATHENS_BUILD_MODE, using mock"
        export ATHENS_BUILD_MODE="mock"
        ;;
esac

echo "Final build mode: ${ATHENS_BUILD_MODE}"