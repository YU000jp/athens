#!/bin/bash
# Test script to validate repository configuration
# This script tests if the new Maven Central priority configuration is working

set -e

echo "🧪 Testing Athens Repository Configuration"
echo "========================================="

# Check if deps.edn contains the new repository configuration
echo "📋 Checking repository configuration in deps.edn..."
if grep -q ":mvn/repos" deps.edn; then
    echo "✅ Repository configuration found"
    echo "Configured repositories:"
    grep -A 5 ":mvn/repos" deps.edn | head -6
else
    echo "❌ Repository configuration missing"
    exit 1
fi

echo ""

# Test network connectivity to configured repositories
echo "🌐 Testing repository accessibility..."
echo "Maven Central:"
if curl -s --connect-timeout 5 --max-time 10 https://repo1.maven.org/maven2/ > /dev/null; then
    echo "✅ repo1.maven.org (Maven Central) - accessible"
else
    echo "❌ repo1.maven.org (Maven Central) - not accessible"
fi

echo "Sonatype:"
if curl -s --connect-timeout 5 --max-time 10 https://oss.sonatype.org/content/repositories/public/ > /dev/null; then
    echo "✅ oss.sonatype.org - accessible"
else
    echo "❌ oss.sonatype.org - not accessible"  
fi

echo "Clojars:"
if curl -s --connect-timeout 5 --max-time 10 https://repo.clojars.org/ > /dev/null; then
    echo "✅ repo.clojars.org - accessible"
else
    echo "❌ repo.clojars.org - not accessible (expected in restricted environments)"
fi

echo ""

# Test if pre-cache script exists and is executable
echo "🔧 Checking build scripts..."
if [ -x "./script/pre-cache-deps.sh" ]; then
    echo "✅ Pre-cache dependency script is available and executable"
else
    echo "❌ Pre-cache dependency script missing or not executable"
    exit 1
fi

# Check if yarn command includes the new deps:cache command
if grep -q "deps:cache" package.json; then
    echo "✅ yarn deps:cache command configured"
else
    echo "❌ yarn deps:cache command not found in package.json"
fi

echo ""
echo "🎉 Repository configuration test completed!"
echo ""
echo "💡 Usage examples:"
echo "  yarn deps:cache          # Pre-cache dependencies"  
echo "  clojure -P               # Resolve dependencies (uses new repo priority)"
echo "  yarn prod                # Full production build"