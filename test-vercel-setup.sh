#!/usr/bin/env bash
# Test Vercel setup locally

set -e

echo "🧪 Athens Vercel Setup Test"
echo "=========================="

# Clean up previous build
echo "🧹 Cleaning up previous build..."
rm -rf vercel-static

echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
echo "Node.js: $(node --version)"
echo "Yarn: $(yarn --version)"

# Check if Clojure is available
if command -v clojure >/dev/null 2>&1; then
    echo "Clojure: $(clojure --version)"
    CLOJURE_AVAILABLE=true
else
    echo "⚠️  Clojure not available - will use mock/components build"
    CLOJURE_AVAILABLE=false
fi

# Check Java
if command -v java >/dev/null 2>&1; then
    echo "Java: $(java --version | head -1)"
else
    echo "❌ Java not available"
    exit 1
fi

echo ""

# Run the actual Vercel build process
echo "🏗️  Testing Vercel build process..."
echo "================================"

if yarn vercel:install; then
    echo "✅ Vercel install successful"
else
    echo "❌ Vercel install failed"
    exit 1
fi

echo ""

if yarn vercel:build; then
    echo "✅ Vercel build successful"
else
    echo "❌ Vercel build failed"
    exit 1
fi

echo ""

# Verify output
echo "📋 Verifying build output..."
if [ -d "vercel-static" ]; then
    echo "✅ vercel-static directory created"
    
    if [ -f "vercel-static/index.html" ]; then
        echo "✅ Main navigation page created"
    else
        echo "⚠️  Main navigation page missing"
    fi
    
    if [ -f "vercel-static/athens/index.html" ]; then
        echo "✅ Athens app page created"
    else
        echo "❌ Athens app page missing"
    fi
    
    if [ -f "vercel-static/clerk/index.html" ]; then
        echo "✅ Clerk notebooks page created"
    else
        echo "❌ Clerk notebooks page missing"
    fi
    
    echo ""
    echo "📊 Build contents:"
    find vercel-static -name "*.html" | sort
    echo ""
    echo "📦 Component files:"
    if [ -d "src/gen/components" ]; then
        echo "$(find src/gen/components -name "*.js" | wc -l) JavaScript files generated"
    else
        echo "⚠️  No component files found"
    fi
    
else
    echo "❌ vercel-static directory not created"
    exit 1
fi

echo ""

# Start local server for testing
echo "🌐 Starting local preview server..."
echo "Visit http://localhost:3001 to view the result"
echo "Press Ctrl+C to stop the server"
echo ""

cd vercel-static && npx serve -l 3001