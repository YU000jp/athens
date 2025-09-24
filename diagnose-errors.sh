#!/usr/bin/env bash
# Athens Error Diagnosis Script
# This script helps identify and resolve common Athens setup and build errors

set -e

echo "🔍 Athens Error Diagnosis"
echo "========================="
echo "Build Time: $(date)"
echo ""

# Function to check command availability
check_command() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $name: Available ($(which "$cmd"))"
        if [ "$cmd" = "node" ] || [ "$cmd" = "yarn" ] || [ "$cmd" = "java" ]; then
            echo "   Version: $($cmd --version 2>/dev/null || $cmd -version 2>/dev/null || echo "Unknown")"
        fi
        return 0
    else
        echo "❌ $name: Not found"
        return 1
    fi
}

# Function to check network connectivity
check_network() {
    local url="$1"
    local service="$2"
    local timeout="5"
    
    if timeout "$timeout" curl -s --connect-timeout 3 "$url" >/dev/null 2>&1; then
        echo "✅ $service: Accessible"
        return 0
    else
        echo "❌ $service: Blocked or unavailable"
        return 1
    fi
}

# Function to check file existence and permissions
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo "✅ $description: Found"
        if [ -x "$file" ]; then
            echo "   Permissions: Executable"
        else
            echo "   Permissions: Not executable"
        fi
        return 0
    else
        echo "❌ $description: Missing"
        return 1
    fi
}

# Basic system requirements
echo "📋 System Requirements Check"
echo "----------------------------"
check_command "node" "Node.js"
check_command "yarn" "Yarn"
check_command "npm" "npm"
check_command "java" "Java"
check_command "clojure" "Clojure CLI"
check_command "git" "Git"
echo ""

# Network connectivity
echo "🌐 Network Connectivity Check"
echo "------------------------------"
check_network "https://registry.npmjs.org/" "npm Registry"
check_network "https://repo1.maven.org/maven2/" "Maven Central"
check_network "https://repo.clojars.org/" "Clojars"
check_network "https://download.clojure.org/" "Clojure Downloads"
echo ""

# Project files and structure
echo "📁 Project Files Check"
echo "----------------------"
check_file "package.json" "Package.json"
check_file "yarn.lock" "Yarn Lock"
check_file "deps.edn" "Clojure Dependencies"
check_file "shadow-cljs.edn" "Shadow-CLJS Config"
check_file "karma.conf.js" "Karma Config"
check_file "vercel.json" "Vercel Config"
echo ""

# Enhanced scripts
echo "🔧 Enhanced Scripts Check"
echo "-------------------------"
check_file "vercel-enhanced-setup.sh" "Enhanced Vercel Setup"
check_file "vercel-enhanced-build.sh" "Enhanced Vercel Build"
check_file "browser-date-handler.js" "Browser Date Handler"
check_file "cldr-enhanced-init.js" "Enhanced CLDR Init"
echo ""

# Dependencies
echo "📦 Dependencies Check"
echo "--------------------"
if [ -d "node_modules" ]; then
    node_modules_count=$(ls node_modules/ | wc -l 2>/dev/null || echo "0")
    echo "✅ Node modules: Found ($node_modules_count packages)"
    
    # Check specific important packages
    important_packages=("@babel/cli" "@babel/core" "shadow-cljs" "karma")
    for pkg in "${important_packages[@]}"; do
        if [ -d "node_modules/$pkg" ]; then
            echo "   ✅ $pkg: Installed"
        else
            echo "   ❌ $pkg: Missing"
        fi
    done
else
    echo "❌ Node modules: Not found (run 'yarn install')"
fi

if [ -d ".cpcache" ]; then
    echo "✅ Clojure cache: Found"
else
    echo "❌ Clojure cache: Not found (run 'clojure -P')"
fi
echo ""

# Build artifacts
echo "🏗️  Build Artifacts Check"
echo "-------------------------"
if [ -d "src/gen/components" ]; then
    components_count=$(find src/gen/components -name "*.js" | wc -l 2>/dev/null || echo "0")
    echo "✅ Generated components: Found ($components_count files)"
else
    echo "❌ Generated components: Not found (run 'yarn components')"
fi

if [ -d "resources/public/js" ]; then
    echo "✅ ClojureScript build: Found"
else
    echo "❌ ClojureScript build: Not found (run 'yarn dev' or 'yarn prod')"
fi

if [ -d "vercel-static" ]; then
    echo "✅ Vercel static: Found"
else
    echo "❌ Vercel static: Not found (run 'yarn vercel:build')"
fi
echo ""

# Common error diagnosis
echo "🩺 Common Error Diagnosis"
echo "------------------------"

# Babel not found error
if ! command -v babel >/dev/null 2>&1 && [ ! -f "node_modules/.bin/babel" ]; then
    echo "🔍 ISSUE: Babel not found"
    echo "   Problem: 'babel: not found' error when running 'yarn components'"
    echo "   Solution: Run 'yarn install' to install missing dependencies"
    echo ""
fi

# Clojure access issues
if ! check_network "https://repo.clojars.org/" "Clojars" >/dev/null 2>&1; then
    echo "🔍 ISSUE: Clojars access blocked"
    echo "   Problem: Cannot access repo.clojars.org for Clojure dependencies"
    echo "   Solution: Use alternative dependency configuration:"
    echo "     cp deps-no-clojars.edn deps.edn"
    echo "     Or use browser-only solutions:"
    echo "     cp karma-no-clojars.conf.js karma.conf.js"
    echo ""
fi

# Vercel build issues
if [ -f "vercel.json" ] && ! check_network "https://repo.clojars.org/" "Clojars" >/dev/null 2>&1; then
    echo "🔍 ISSUE: Vercel deployment restrictions"
    echo "   Problem: Network restrictions prevent full Clojure build"
    echo "   Solution: Use enhanced Vercel build system:"
    echo "     yarn vercel:build:enhanced"
    echo "   Or GitHub Actions pre-build deployment"
    echo ""
fi

# Missing Java/Clojure
if ! command -v clojure >/dev/null 2>&1; then
    echo "🔍 ISSUE: Clojure CLI not available"
    echo "   Problem: ClojureScript compilation will fail"
    echo "   Solution: Install Clojure CLI or use JavaScript-only mode"
    echo ""
fi

# Recommendations
echo "💡 Recommended Next Steps"
echo "------------------------"

if [ ! -d "node_modules" ]; then
    echo "1. Install Node.js dependencies:"
    echo "   yarn install"
    echo ""
fi

if ! command -v clojure >/dev/null 2>&1; then
    echo "2. For full Athens functionality, install Clojure:"
    echo "   curl -O https://download.clojure.org/install/linux-install.sh"
    echo "   chmod +x linux-install.sh"
    echo "   ./linux-install.sh"
    echo ""
    echo "   Alternative: Use JavaScript-only mode for testing"
    echo ""
fi

if ! check_network "https://repo.clojars.org/" "Clojars" >/dev/null 2>&1; then
    echo "3. For restricted networks, use alternative configurations:"
    echo "   cp karma-no-clojars.conf.js karma.conf.js  # For testing"
    echo "   cp deps-no-clojars.edn deps.edn           # For development"
    echo ""
fi

echo "4. Build components and test:"
echo "   yarn components      # Build JavaScript components"
echo "   yarn client:test     # Run tests"
echo "   yarn dev             # Start development server"
echo ""

echo "5. For Vercel deployment:"
echo "   yarn vercel:build:enhanced  # Enhanced build with fallbacks"
echo ""

# Summary
error_count=0
if ! command -v node >/dev/null 2>&1; then ((error_count++)); fi
if ! command -v yarn >/dev/null 2>&1; then ((error_count++)); fi
if [ ! -d "node_modules" ]; then ((error_count++)); fi

echo "📊 Summary"
echo "----------"
if [ $error_count -eq 0 ]; then
    echo "✅ Basic setup appears correct. If you're still seeing errors,"
    echo "   please run the specific command that's failing for detailed output."
else
    echo "⚠️  Found $error_count critical issues that need to be resolved."
    echo "   Please follow the recommended next steps above."
fi

echo ""
echo "For more help, see:"
echo "• CLDR_TROUBLESHOOTING.md - CLDR and date handling issues"
echo "• VERCEL_DEPLOYMENT_GUIDE.md - Vercel deployment problems"  
echo "• CLOJARS_ALTERNATIVES.md - Network restriction solutions"
echo ""
echo "Report generated: $(date)"