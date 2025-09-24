#!/usr/bin/env bash
# Test Vercel setup locally

set -e

echo "🧪 Athens Vercel Setup Test"
echo "=========================="

# Check prerequisites
echo "📋 Checking prerequisites..."
echo "Node.js: $(node --version)"
echo "Yarn: $(yarn --version)"

# Check if Clojure is available
if command -v clojure >/dev/null 2>&1; then
    echo "Clojure: $(clojure --version)"
    CLOJURE_AVAILABLE=true
else
    echo "⚠️  Clojure not available - will use mock build"
    CLOJURE_AVAILABLE=false
fi

echo ""

# Install dependencies
echo "📦 Installing Node.js dependencies..."
yarn install

echo ""

# Try to build
echo "🏗️  Testing build process..."
if [ "$CLOJURE_AVAILABLE" = true ]; then
    echo "Attempting full Vercel build..."
    if yarn vercel:build; then
        echo "✅ Full Vercel build successful!"
    else
        echo "❌ Full build failed, falling back to mock build..."
        ./mock-vercel-build.sh
    fi
else
    echo "Using mock build due to missing Clojure..."
    ./mock-vercel-build.sh
fi

echo ""

# Start local server for testing
echo "🌐 Starting local preview server..."
echo "Visit http://localhost:3001 to view the result"
echo "Press Ctrl+C to stop the server"

npx serve vercel-static -l 3001