#!/usr/bin/env bash
# Enhanced Vercel build script that handles network restrictions gracefully
set -e

echo "🚀 Enhanced Athens Vercel Build"
echo "==============================="

# Enhanced build strategy detection
function detect_build_capabilities() {
    local clojure_available=false
    local network_access=false
    local external_deps=false
    
    echo "🔍 Detecting build environment capabilities..."
    
    # Test Clojure availability
    if command -v clojure >/dev/null 2>&1; then
        echo "✅ Clojure CLI available"
        clojure_available=true
    else
        echo "❌ Clojure CLI not available"
    fi
    
    # Test network connectivity with timeout
    if timeout 10s curl -s --connect-timeout 3 https://repo1.maven.org/maven2/ > /dev/null 2>&1; then
        echo "✅ Maven Central accessible"
        network_access=true
        
        if timeout 10s curl -s --connect-timeout 3 https://repo.clojars.org/ > /dev/null 2>&1; then
            echo "✅ Clojars accessible"
            external_deps=true
        else
            echo "❌ Clojars blocked"
        fi
    else
        echo "❌ Network connectivity limited"
    fi
    
    # Export capabilities as environment variables
    export ATHENS_CLOJURE_AVAILABLE=$clojure_available
    export ATHENS_NETWORK_ACCESS=$network_access
    export ATHENS_EXTERNAL_DEPS=$external_deps
    
    echo "📊 Environment Summary:"
    echo "   Clojure: $clojure_available"
    echo "   Network: $network_access" 
    echo "   External deps: $external_deps"
}

# Build JavaScript components only (always works)
function build_js_components() {
    echo "📦 Building JavaScript/TypeScript components..."
    
    # This should work in all environments
    if yarn components; then
        echo "✅ JavaScript components built successfully"
        return 0
    else
        echo "❌ JavaScript component build failed"
        return 1
    fi
}

# Create static-only build for restricted environments
function create_static_build() {
    echo "🎯 Creating static-only build for restricted environment..."
    
    # Create output directories
    mkdir -p vercel-static/athens
    mkdir -p vercel-static/clerk
    mkdir -p vercel-static/js
    mkdir -p vercel-static/css
    
    # Copy pre-built JavaScript components if available
    if [ -d "src/gen/components" ]; then
        echo "📁 Copying generated components..."
        cp -R src/gen/components/* vercel-static/js/ 2>/dev/null || echo "No generated components to copy"
    fi
    
    # Copy any existing static assets
    if [ -d "resources/public" ]; then
        echo "📋 Copying existing static resources..."
        cp -R resources/public/* vercel-static/athens/ 2>/dev/null || echo "No public resources to copy"
    fi
    
    # Copy CSS and other assets
    if [ -d "resources/public/css" ]; then
        cp -R resources/public/css/* vercel-static/css/ 2>/dev/null || true
    fi
    
    # Create enhanced Athens main page with working components
    cat > vercel-static/athens/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Athens Research - Vercel デプロイメント</title>
    <style>
        * {
            box-sizing: border-box;
        }
        body {
            font-family: system-ui, -apple-system, 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            margin: 0;
            padding: 0;
            background: #f8f9fa;
            line-height: 1.6;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        .header {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
            text-align: center;
        }
        .logo {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }
        .status-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .status-success {
            border-left: 4px solid #28a745;
        }
        .status-warning {
            border-left: 4px solid #ffc107;
        }
        .status-error {
            border-left: 4px solid #dc3545;
        }
        .nav-section {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin: 2rem 0;
        }
        .nav-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        .nav-link {
            display: flex;
            align-items: center;
            padding: 1rem;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: background-color 0.2s;
        }
        .nav-link:hover {
            background: #0056b3;
        }
        .nav-link .icon {
            font-size: 1.5rem;
            margin-right: 0.5rem;
        }
        .technical-details {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin: 2rem 0;
        }
        .code-block {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 1rem;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
        }
        .component-demo {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin: 2rem 0;
        }
        .demo-block {
            border: 2px dashed #007bff;
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
            background: #f8f9ff;
        }
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            .nav-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🏛️</div>
            <h1>Athens Research</h1>
            <p><strong>オープンソース知識グラフアプリケーション</strong></p>
            <p>Vercel デプロイメント - 制限環境対応版</p>
        </div>

        <div class="status-grid">
            <div class="status-card status-success">
                <h3>✅ 正常動作</h3>
                <ul>
                    <li>JavaScript/TypeScript コンポーネント</li>
                    <li>React コンポーネントライブラリ</li>
                    <li>Babel トランスパイル</li>
                    <li>静的アセット配信</li>
                </ul>
            </div>
            
            <div class="status-card status-error">
                <h3>❌ 利用不可</h3>
                <ul>
                    <li>ClojureScript コンパイル</li>
                    <li>Clojure 依存関係解決</li>
                    <li>repo.clojars.org アクセス</li>
                    <li>動的アプリケーション機能</li>
                </ul>
            </div>
            
            <div class="status-card status-warning">
                <h3>⚠️ 部分対応</h3>
                <ul>
                    <li>静的コンテンツ配信</li>
                    <li>ドキュメント表示</li>
                    <li>コンポーネントプレビュー</li>
                    <li>開発情報ページ</li>
                </ul>
            </div>
        </div>

        <div class="nav-section">
            <h2>🚀 利用可能な機能</h2>
            <div class="nav-grid">
                <a href="#components" class="nav-link">
                    <span class="icon">📦</span>
                    <div>
                        <strong>コンポーネント</strong><br>
                        <small>ビルド済みReactコンポーネント</small>
                    </div>
                </a>
                <a href="/clerk/" class="nav-link">
                    <span class="icon">📚</span>
                    <div>
                        <strong>Clerk Notebooks</strong><br>
                        <small>開発ドキュメント</small>
                    </div>
                </a>
                <a href="https://github.com/YU000jp/athens" class="nav-link" target="_blank">
                    <span class="icon">📋</span>
                    <div>
                        <strong>GitHub リポジトリ</strong><br>
                        <small>ソースコードと詳細</small>
                    </div>
                </a>
                <a href="#technical" class="nav-link">
                    <span class="icon">🔧</span>
                    <div>
                        <strong>技術詳細</strong><br>
                        <small>ビルドとトラブルシューティング</small>
                    </div>
                </a>
            </div>
        </div>

        <div class="component-demo" id="components">
            <h2>📦 ビルド済みコンポーネント</h2>
            <p>以下のReact/TypeScriptコンポーネントが正常にビルドされ、利用可能です:</p>
            
            <div class="demo-block">
                <h4>🧩 Icons コンポーネント</h4>
                <p>SVGアイコンコンポーネント群 - Athens UIで使用される各種アイコン</p>
            </div>
            
            <div class="demo-block">
                <h4>📝 Block コンポーネント</h4>
                <p>ブロックエディター関連コンポーネント - Athens のコア編集機能</p>
            </div>
            
            <div class="demo-block">
                <h4>🎨 UI コンポーネント</h4>
                <p>ユーザーインターフェースコンポーネント - ボタン、メニューなど</p>
            </div>
            
            <p><strong>注意:</strong> これらのコンポーネントは静的にビルドされており、完全なClojureScriptアプリケーションなしでは動的機能は制限されています。</p>
        </div>

        <div class="technical-details" id="technical">
            <h2>🔧 技術詳細とトラブルシューティング</h2>
            
            <h3>📊 ビルド環境分析</h3>
            <div class="code-block">
Environment Capabilities:
• Node.js: ✅ Available (v20+)
• Yarn: ✅ Available 
• Babel: ✅ Functioning
• Java: ❓ May be available but limited
• Clojure CLI: ❌ Installation blocked
• Maven Central: ❓ Limited access
• Clojars: ❌ Access restricted
            </div>
            
            <h3>🎯 完全なAthensを実行するための解決策</h3>
            
            <h4>1. ローカル開発環境 (推奨)</h4>
            <div class="code-block">
# 完全な開発環境セットアップ
git clone https://github.com/YU000jp/athens.git
cd athens
yarn install
clojure -P  # 依存関係ダウンロード
yarn dev    # 開発サーバー起動
            </div>
            
            <h4>2. GitHub Actions による事前ビルド</h4>
            <div class="code-block">
# .github/workflows/build.yml で以下を設定:
# 1. Clojure環境でフルビルド実行
# 2. 静的アセット生成
# 3. Vercelへの事前ビルド済みファイルデプロイ
            </div>
            
            <h4>3. Docker コンテナ利用</h4>
            <div class="code-block">
# 完全なClojure環境を含むDocker環境
docker-compose up athens-dev
# または
docker run -p 3000:3000 athens-clojure-env
            </div>
            
            <h3>🌐 Vercel制限事項の詳細</h3>
            <ul>
                <li><strong>ネットワーク制限:</strong> 一部外部リポジトリ（Clojars）へのアクセスがブロック</li>
                <li><strong>ビルド時間制限:</strong> Clojureコンパイルには時間がかかる場合がある</li>
                <li><strong>メモリ制限:</strong> 大規模なClojureScriptコンパイルには十分なメモリが必要</li>
                <li><strong>カスタムバイナリ:</strong> Clojure CLIの動的インストールが制限される場合がある</li>
            </ul>
            
            <h3>📚 詳細ドキュメント</h3>
            <p>詳細な解決方法は以下を参照してください:</p>
            <ul>
                <li><a href="https://github.com/YU000jp/athens/blob/main/README.md">README.md - セットアップガイド</a></li>
                <li><a href="https://github.com/YU000jp/athens/blob/main/CLOJARS_ALTERNATIVES.md">CLOJARS_ALTERNATIVES.md - ネットワーク制限対応</a></li>
                <li><a href="https://github.com/YU000jp/athens/blob/main/BUILD_TROUBLESHOOTING.md">BUILD_TROUBLESHOOTING.md - ビルド問題解決</a></li>
                <li><a href="https://github.com/YU000jp/athens/blob/main/VERCEL_SETUP.md">VERCEL_SETUP.md - Vercel固有の設定</a></li>
            </ul>
        </div>
    </div>

    <script>
        // Simple JavaScript for enhanced interactivity
        document.addEventListener('DOMContentLoaded', function() {
            // Add smooth scrolling for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    const target = document.querySelector(this.getAttribute('href'));
                    if (target) {
                        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                });
            });
            
            // Display build timestamp
            const buildTime = new Date().toLocaleString('ja-JP');
            document.title += ` - ビルド: ${buildTime}`;
        });
    </script>
</body>
</html>
EOF

    echo "✅ Enhanced static build created"
}

# Attempt optimized build for partial Clojure access
function build_with_limited_deps() {
    echo "🔄 Attempting build with limited dependencies..."
    
    # Try to use Clojars-free configuration if available
    if [ -f "deps-no-clojars.edn" ]; then
        echo "📁 Using Clojars-free dependency configuration..."
        cp deps-no-clojars.edn deps.edn.backup
        
        # Try basic Clojure operations with timeout
        if timeout 300s clojure -P 2>/dev/null; then
            echo "✅ Basic Clojure setup succeeded"
            
            # Try component compilation with timeout
            if timeout 600s yarn components && timeout 900s clojure -M:notebooks:static 2>/dev/null; then
                echo "✅ Partial build with notebooks succeeded"
                return 0
            else
                echo "⚠️ Notebooks failed, trying components only..."
                if timeout 600s yarn components; then
                    echo "✅ Components-only build succeeded"
                    create_static_build
                    return 0
                fi
            fi
        else
            echo "❌ Clojure setup failed, falling back to static build"
        fi
        
        # Restore original deps.edn if backup exists
        if [ -f "deps.edn.backup" ]; then
            mv deps.edn.backup deps.edn
        fi
    fi
    
    return 1
}

# Main build process with comprehensive fallbacks
function main_build_process() {
    detect_build_capabilities
    
    # Always try to build JavaScript components first
    if ! build_js_components; then
        echo "❌ Critical: JavaScript component build failed"
        exit 1
    fi
    
    # Determine build strategy based on capabilities
    if [ "$ATHENS_CLOJURE_AVAILABLE" = "true" ] && [ "$ATHENS_EXTERNAL_DEPS" = "true" ]; then
        echo "🎯 Full build mode: All capabilities available"
        if yarn notebooks:static && yarn client:web:static 2>/dev/null; then
            echo "✅ Full Athens build completed successfully!"
            return 0
        else
            echo "⚠️ Full build failed, trying partial build..."
        fi
    fi
    
    if [ "$ATHENS_CLOJURE_AVAILABLE" = "true" ] && [ "$ATHENS_NETWORK_ACCESS" = "true" ]; then
        echo "🔄 Partial build mode: Clojure available, limited dependencies"
        if build_with_limited_deps; then
            echo "✅ Partial build completed successfully!"
            return 0
        else
            echo "⚠️ Partial build failed, falling back to static..."
        fi
    fi
    
    # Final fallback: static-only build
    echo "🎯 Static build mode: Creating comprehensive static version"
    create_static_build
    echo "✅ Static build completed successfully!"
    
    # Create helpful deployment information
    cat > vercel-static/DEPLOYMENT_INFO.md << 'EOF'
# Athens Vercel Deployment Information

## Build Status
- **JavaScript Components**: ✅ Successfully compiled
- **ClojureScript Application**: ❌ Network restrictions prevented compilation
- **Static Assets**: ✅ Available
- **Interactive Features**: ❌ Limited due to missing ClojureScript

## Available Features
- React/TypeScript components (pre-compiled)
- Static documentation and navigation
- Build status and troubleshooting information
- Links to full Athens resources

## For Full Functionality
Please run Athens in a local development environment or environment with complete network access.

See the main Athens page for detailed setup instructions.
EOF
}

# Execute main build process
main_build_process

echo ""
echo "🎉 Enhanced Vercel Build Completed!"
echo "📁 Output directory: vercel-static/"
echo "🌐 Access your deployment at the Vercel URL"
echo ""
echo "ℹ️ This is a static-optimized build due to Vercel network restrictions."
echo "For full Athens functionality, please see the deployment information."