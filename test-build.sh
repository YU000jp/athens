#!/bin/bash
# Build verification script for Athens project
# Run this to test if the build process works after network issues are resolved

set -e

echo "🧪 Athens Build Verification Script"
echo "=================================="

echo "📋 Checking prerequisites..."
echo "Java version:"
java --version
echo
echo "Node.js version:"
node --version
echo
echo "Yarn version:"
yarn --version
echo
echo "Clojure CLI version:"
clojure --version
echo

echo "🌐 Testing network connectivity..."
echo "Testing Maven Central:"
curl -I https://repo1.maven.org/maven2/ || echo "❌ Maven Central unreachable"
echo
echo "Testing Clojars:"
curl -I https://repo.clojars.org/ || echo "❌ Clojars unreachable"
echo

echo "📦 Installing Node.js dependencies..."
yarn install --frozen-lockfile
echo "✅ Node.js dependencies installed"
echo

echo "🔧 Building JavaScript components..."
yarn components
echo "✅ JavaScript components built"
echo

echo "📚 Fetching Clojure dependencies..."
clojure -P
echo "✅ Clojure dependencies fetched"
echo

echo "🏗️  Testing Shadow-CLJS compilation..."
npx shadow-cljs compile app --verbose
echo "✅ Shadow-CLJS compilation successful"
echo

echo "🚀 Testing production build..."
yarn prod
echo "✅ Production build successful"
echo

echo "🎉 All build steps completed successfully!"
echo "The Athens build process is working correctly."