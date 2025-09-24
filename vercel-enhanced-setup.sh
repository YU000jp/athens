#!/usr/bin/env bash
# Enhanced Vercel setup script with comprehensive fallback strategies
set -eo pipefail

echo "🔧 Enhanced Athens Vercel Setup"
echo "==============================="

# Environment detection functions
detect_java() {
    if command -v java >/dev/null 2>&1; then
        echo "✅ Java detected: $(java -version 2>&1 | head -1)"
        return 0
    else
        echo "❌ Java not available"
        return 1
    fi
}

detect_node() {
    if command -v node >/dev/null 2>&1; then
        echo "✅ Node.js detected: $(node --version)"
        return 0
    else
        echo "❌ Node.js not available"
        return 1
    fi
}

test_network_connectivity() {
    local test_urls=(
        "https://repo1.maven.org/maven2/"
        "https://repo.clojars.org/"
        "https://download.clojure.org/"
        "https://registry.npmjs.org/"
    )
    
    local accessible_repos=()
    local blocked_repos=()
    
    echo "🌐 Testing network connectivity..."
    
    for url in "${test_urls[@]}"; do
        local service_name=$(echo "$url" | sed 's|https://||' | sed 's|/.*||')
        
        if timeout 10s curl -s --connect-timeout 3 "$url" >/dev/null 2>&1; then
            echo "✅ $service_name accessible"
            accessible_repos+=("$service_name")
        else
            echo "❌ $service_name blocked/unavailable"
            blocked_repos+=("$service_name")
        fi
    done
    
    export ATHENS_ACCESSIBLE_REPOS="${accessible_repos[*]}"
    export ATHENS_BLOCKED_REPOS="${blocked_repos[*]}"
    
    # Determine network access level
    if [[ " ${accessible_repos[*]} " =~ " repo.clojars.org " ]] && [[ " ${accessible_repos[*]} " =~ " repo1.maven.org " ]]; then
        export ATHENS_NETWORK_LEVEL="full"
        echo "🎯 Network Level: FULL (Maven Central + Clojars accessible)"
    elif [[ " ${accessible_repos[*]} " =~ " repo1.maven.org " ]]; then
        export ATHENS_NETWORK_LEVEL="partial"
        echo "🎯 Network Level: PARTIAL (Maven Central only)"
    else
        export ATHENS_NETWORK_LEVEL="restricted"
        echo "🎯 Network Level: RESTRICTED (Limited access)"
    fi
}

install_clojure_with_fallbacks() {
    echo "🔄 Attempting Clojure CLI installation with multiple strategies..."
    
    # Strategy 1: Official installer
    if timeout 60s curl -s -O https://download.clojure.org/install/linux-install-1.11.1.1435.sh 2>/dev/null; then
        chmod +x linux-install-1.11.1.1435.sh
        if timeout 120s ./linux-install-1.11.1.1435.sh 2>/dev/null; then
            echo "✅ Clojure CLI installed via official installer"
            clojure --version
            export ATHENS_CLOJURE_METHOD="official"
            return 0
        else
            echo "⚠️ Official installer failed"
        fi
    else
        echo "⚠️ Cannot download official installer"
    fi
    
    # Strategy 2: Package manager
    if command -v apt-get >/dev/null 2>&1; then
        echo "🔄 Attempting apt-get installation..."
        if timeout 120s sudo apt-get update >/dev/null 2>&1 && timeout 180s sudo apt-get install -y clojure >/dev/null 2>&1; then
            echo "✅ Clojure CLI installed via apt-get"
            export ATHENS_CLOJURE_METHOD="apt"
            return 0
        else
            echo "⚠️ apt-get installation failed"
        fi
    fi
    
    # Strategy 3: Manual installation to local directory
    echo "🔄 Attempting manual local installation..."
    mkdir -p "$HOME/.local/bin" || true
    
    if timeout 60s curl -s -o clojure.tar.gz "https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh" 2>/dev/null; then
        echo "⚠️ Manual installation not implemented in this version"
    fi
    
    echo "❌ All Clojure installation strategies failed"
    export ATHENS_CLOJURE_METHOD="none"
    return 1
}

create_alternative_deps_config() {
    echo "🔧 Creating alternative dependency configurations..."
    
    # Create Clojars-free deps.edn if it doesn't exist
    if [ ! -f "deps-no-clojars.edn" ]; then
        echo "📝 Creating Maven Central only dependency configuration..."
        cat > deps-no-clojars.edn << 'EOF'
{:paths ["src/clj" "src/cljs" "src/cljc" "src/js" "src/gen" "test" "resources"]

 :mvn/repos
 {"central" {:url "https://repo1.maven.org/maven2/"}
  "sonatype" {:url "https://oss.sonatype.org/content/repositories/public/"}}

 :deps
 {org.clojure/clojure #:mvn{:version "1.11.1"}
  org.clojure/clojurescript #:mvn{:version "1.11.60"}
  thheller/shadow-cljs #:mvn{:version "2.19.5"}
  reagent/reagent #:mvn{:version "1.0.0"}
  re-frame/re-frame #:mvn{:version "1.2.0"}
  cljc.java-time/cljc.java-time #:mvn{:version "0.1.9"}}
 
 :aliases
 {:shadow-cljs {:extra-deps {thheller/shadow-cljs #:mvn{:version "2.19.5"}}
                :main-opts ["-m" "shadow.cljs.devtools.cli"]}}}
EOF
    fi
    
    # Backup original deps.edn
    if [ -f "deps.edn" ] && [ ! -f "deps.edn.original" ]; then
        cp deps.edn deps.edn.original
        echo "📋 Backed up original deps.edn"
    fi
    
    # Use appropriate deps based on network access
    case "$ATHENS_NETWORK_LEVEL" in
        "full")
            echo "🎯 Using original deps.edn (full network access)"
            ;;
        "partial"|"restricted")
            echo "🎯 Using Clojars-free deps.edn (limited network access)"
            cp deps-no-clojars.edn deps.edn
            ;;
    esac
}

setup_browser_date_handler() {
    echo "📅 Setting up browser-only date handler..."
    
    # Ensure browser date handler is available
    if [ ! -f "browser-date-handler.js" ]; then
        echo "⚠️ Browser date handler not found, creating minimal version..."
        cat > browser-date-handler.js << 'EOF'
// Minimal browser date handler for Vercel deployment
window.AthensDateHandler = {
    formatUSDate: function(date) {
        const d = new Date(date);
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const year = d.getFullYear();
        return `${month}-${day}-${year}`;
    },
    
    formatTitle: function(date) {
        const d = new Date(date);
        return d.toLocaleDateString('en-US', {
            year: 'numeric', month: 'long', day: 'numeric'
        });
    },
    
    parseUID: function(uid) {
        if (!uid) return null;
        const match = uid.match(/^(\d{2})-(\d{2})-(\d{4})$/);
        return match ? new Date(match[3], match[1] - 1, match[2]) : null;
    },
    
    getDayWithOffset: function(offset = 0) {
        const date = new Date();
        date.setDate(date.getDate() + offset);
        return {
            uid: this.formatUSDate(date),
            title: this.formatTitle(date),
            inst: date
        };
    }
};
console.log('✅ Minimal Athens Date Handler initialized');
EOF
        echo "✅ Minimal browser date handler created"
    else
        echo "✅ Browser date handler already available"
    fi
}

configure_package_scripts() {
    echo "📦 Configuring package.json for Vercel deployment..."
    
    # Check if vercel scripts exist, add them if missing
    if ! grep -q "vercel:install" package.json; then
        echo "🔧 Adding missing Vercel scripts to package.json..."
        
        # Create a temporary script to add Vercel scripts
        cat > add-vercel-scripts.js << 'EOF'
const fs = require('fs');
const path = './package.json';
const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));

// Add Vercel-specific scripts if they don't exist
pkg.scripts = pkg.scripts || {};

if (!pkg.scripts['vercel:install']) {
    pkg.scripts['vercel:install'] = './vercel-enhanced-setup.sh && yarn';
}

if (!pkg.scripts['vercel:build']) {
    pkg.scripts['vercel:build'] = './vercel-enhanced-build.sh';
}

// Add fallback scripts for different build modes
pkg.scripts['vercel:build:full'] = 'yarn notebooks:static && yarn client:web:static';
pkg.scripts['vercel:build:partial'] = 'yarn components && yarn notebooks:static';
pkg.scripts['vercel:build:static'] = 'yarn components && ./vercel-enhanced-build.sh';

fs.writeFileSync(path, JSON.stringify(pkg, null, 2));
console.log('✅ Vercel scripts added to package.json');
EOF
        
        node add-vercel-scripts.js
        rm add-vercel-scripts.js
    else
        echo "✅ Vercel scripts already configured"
    fi
}

optimize_vercel_config() {
    echo "⚙️ Optimizing vercel.json configuration..."
    
    # Backup original vercel.json if it exists
    if [ -f "vercel.json" ] && [ ! -f "vercel.json.original" ]; then
        cp vercel.json vercel.json.original
        echo "📋 Backed up original vercel.json"
    fi
    
    # Create enhanced vercel.json with multiple build strategies
    cat > vercel.json << 'EOF'
{
  "version": 2,
  "name": "athens",
  "build": {
    "env": {
      "NODE_VERSION": "20",
      "ATHENS_BUILD_MODE": "auto",
      "JAVA_TOOL_OPTIONS": "-Xmx2g"
    }
  },
  "buildCommand": "yarn vercel:build",
  "outputDirectory": "vercel-static",
  "installCommand": "yarn vercel:install",
  "framework": null,
  "public": false,
  "functions": {
    "pages/api/**/*.js": {
      "runtime": "nodejs18.x"
    }
  },
  "rewrites": [
    {
      "source": "/athens/(.*)",
      "destination": "/athens/$1"
    },
    {
      "source": "/clerk/(.*)", 
      "destination": "/clerk/$1"
    },
    {
      "source": "/",
      "destination": "/athens/index.html"
    }
  ],
  "headers": [
    {
      "source": "/athens/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=86400"
        },
        {
          "key": "X-Athens-Build",
          "value": "vercel-enhanced"
        }
      ]
    },
    {
      "source": "/static/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=2592000"
        }
      ]
    }
  ]
}
EOF
    echo "✅ Enhanced vercel.json configuration created"
}

main_setup_process() {
    echo "🚀 Starting enhanced Vercel setup process..."
    
    # Basic environment checks
    detect_node || { echo "❌ Node.js is required but not available"; exit 1; }
    detect_java || echo "⚠️ Java not available - some features may be limited"
    
    # Network connectivity analysis
    test_network_connectivity
    
    # Try to install Clojure with multiple strategies
    if install_clojure_with_fallbacks; then
        export ATHENS_CLOJURE_AVAILABLE="true"
        echo "✅ Clojure setup completed successfully"
    else
        export ATHENS_CLOJURE_AVAILABLE="false"
        echo "⚠️ Clojure setup failed - using JavaScript-only build mode"
    fi
    
    # Configure dependencies based on network access
    create_alternative_deps_config
    
    # Set up browser-only date handling
    setup_browser_date_handler
    
    # Configure package.json scripts
    configure_package_scripts
    
    # Optimize Vercel configuration
    optimize_vercel_config
    
    # Export final build strategy
    if [ "$ATHENS_CLOJURE_AVAILABLE" = "true" ] && [ "$ATHENS_NETWORK_LEVEL" = "full" ]; then
        export ATHENS_BUILD_STRATEGY="full"
        echo "🎯 Build Strategy: FULL (Clojure + full network access)"
    elif [ "$ATHENS_CLOJURE_AVAILABLE" = "true" ] && [ "$ATHENS_NETWORK_LEVEL" = "partial" ]; then
        export ATHENS_BUILD_STRATEGY="partial"
        echo "🎯 Build Strategy: PARTIAL (Clojure + Maven Central only)"
    else
        export ATHENS_BUILD_STRATEGY="static"
        echo "🎯 Build Strategy: STATIC (JavaScript components only)"
    fi
    
    # Create setup summary
    cat > vercel-setup-summary.md << EOF
# Athens Vercel Setup Summary

**Setup Date:** $(date -u)

## Environment Analysis
- **Node.js:** $(node --version 2>/dev/null || echo "Not available")
- **Java:** $(java --version 2>&1 | head -1 2>/dev/null || echo "Not available")
- **Clojure:** ${ATHENS_CLOJURE_METHOD:-"Not installed"}

## Network Access
- **Level:** $ATHENS_NETWORK_LEVEL
- **Accessible:** $ATHENS_ACCESSIBLE_REPOS
- **Blocked:** $ATHENS_BLOCKED_REPOS

## Build Configuration
- **Strategy:** $ATHENS_BUILD_STRATEGY
- **Dependencies:** $([ "$ATHENS_NETWORK_LEVEL" = "full" ] && echo "Original deps.edn" || echo "Clojars-free deps.edn")

## Available Features
- ✅ JavaScript/TypeScript components
- ✅ Static asset serving
- ✅ Browser-only date handling
- $([ "$ATHENS_CLOJURE_AVAILABLE" = "true" ] && echo "✅" || echo "❌") ClojureScript compilation
- $([ "$ATHENS_NETWORK_LEVEL" = "full" ] && echo "✅" || echo "❌") Full dependency resolution

For troubleshooting, see the generated deployment documentation.
EOF

    echo "✅ Enhanced Vercel setup completed successfully!"
    echo "📋 Setup summary: vercel-setup-summary.md"
    echo "🎯 Build strategy: $ATHENS_BUILD_STRATEGY"
}

# Execute main setup process
main_setup_process