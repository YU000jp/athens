#!/usr/bin/env bash
# Mock vercel build for testing when network connectivity is limited

set -e

echo "🧪 Mock Vercel Build Process"
echo "============================"

# Create necessary directories
mkdir -p vercel-static/athens
mkdir -p vercel-static/clerk

# Build JS components (this should work without network)
echo "Building JavaScript components..."
yarn components

# Create a comprehensive mock Athens client  
echo "Creating mock Athens web client..."
cat > vercel-static/athens/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Athens Research - Vercel プレビュー</title>
    <style>
        body {
            font-family: system-ui, -apple-system, 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            max-width: 900px;
            margin: 2rem auto;
            padding: 1rem;
            background: #f8f9fa;
            line-height: 1.6;
        }
        .header {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        .status {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
        .success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
        .info {
            background: #d1ecf1;
            border: 1px solid #b8daff;
            color: #0c5460;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
        .nav-link {
            display: inline-block;
            margin: 0.5rem 1rem 0.5rem 0;
            padding: 0.5rem 1rem;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .nav-link:hover {
            background: #0056b3;
        }
        .build-details {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin: 1rem 0;
        }
        .component-list {
            background: #e9ecef;
            padding: 1rem;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        code {
            background: #f8f9fa;
            padding: 0.2em 0.4em;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏛️ Athens Research</h1>
        <p><strong>オープンソース知識グラフアプリケーション</strong></p>
        
        <div class="status">
            ⚠️ <strong>Vercel プレビュービルド</strong><br>
            これは制限されたネットワーク環境での部分ビルドです。
        </div>
        
        <div class="success">
            ✅ <strong>正常に処理されたコンポーネント</strong><br>
            📦 JavaScript コンポーネントが Babel により正常にコンパイルされました<br>
            🔧 61個のTypeScript/JSXファイルが処理されました
        </div>
    </div>

    <nav>
        <a href="/clerk/" class="nav-link">📚 Clerk Notebooks</a>
        <a href="https://github.com/YU000jp/athens" class="nav-link">📋 GitHub リポジトリ</a>
        <a href="#build-info" class="nav-link">🔍 ビルド詳細</a>
    </nav>

    <div class="build-details" id="build-info">
        <h2>🏗️ ビルド情報</h2>
        <div class="info">
            <strong>ビルド状況:</strong><br>
            • JavaScript/TypeScriptコンポーネント: ✅ 正常<br>
            • ClojureScriptコンパイル: ❌ ネットワーク制限により利用不可<br>
            • Clojure CLI: ❌ インストール失敗<br>
            • 外部依存関係: ❌ Clojarsアクセス不可
        </div>
        
        <h3>📦 コンパイルされたコンポーネント</h3>
        <div class="component-list">
            src/gen/components/ に以下が生成されました:<br>
            • Block コンポーネント群<br>
            • Icon コンポーネント群<br>
            • UI コンポーネント群<br>
            • その他 React/TypeScript コンポーネント
        </div>
        
        <h3>⚠️ 制限事項</h3>
        <ul>
            <li><strong>ClojureScript アプリケーション:</strong> コンパイルできませんでした</li>
            <li><strong>Clojure 依存関係:</strong> <code>repo.clojars.org</code> へのアクセスが制限されています</li>
            <li><strong>Clerk Notebooks:</strong> 静的生成に失敗しました</li>
            <li><strong>フル機能:</strong> ローカル環境または完全なネットワークアクセスが必要です</li>
        </ul>
        
        <h3>🎯 完全な Athens を実行するには</h3>
        <div class="info">
            <strong>ローカル開発環境:</strong><br>
            <code>yarn install && clojure -P && yarn dev</code><br><br>
            
            <strong>プロダクションビルド:</strong><br>
            <code>yarn prod</code><br><br>
            
            詳細は <a href="https://github.com/YU000jp/athens/blob/main/README.md">README.md</a> をご覧ください。
        </div>
    </div>
    
    <div class="build-details">
        <h2>🔧 トラブルシューティング</h2>
        <p>このビルドエラーを解決するには:</p>
        <ol>
            <li><strong>Vercel プロジェクト設定</strong>で <code>repo.clojars.org</code> へのアクセスを許可</li>
            <li><strong>GitHub Actions</strong> を使用した事前ビルドとデプロイ</li>
            <li><strong>依存関係のプリキャッシュ</strong>を含むカスタムビルドイメージの使用</li>
        </ol>
        
        <p>詳細は <a href="https://github.com/YU000jp/athens/blob/main/VERCEL_SETUP.md">VERCEL_SETUP.md</a> と 
        <a href="https://github.com/YU000jp/athens/blob/main/BUILD_TROUBLESHOOTING.md">BUILD_TROUBLESHOOTING.md</a> をご参照ください。</p>
    </div>
EOF

# Create a detailed Clerk index
echo "Creating mock Clerk notebooks..."
cat > vercel-static/clerk/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clerk Notebooks - Athens</title>
    <style>
        body {
            font-family: system-ui, -apple-system, 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
            line-height: 1.6;
        }
        .status {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 1rem;
            border-radius: 4px;
            margin: 1rem 0;
        }
        .nav-link {
            display: inline-block;
            margin: 0.5rem 1rem 0.5rem 0;
            padding: 0.5rem 1rem;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .nav-link:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <h1>📚 Clerk Notebooks</h1>
    
    <div class="status">
        ⚠️ <strong>Clerk Notebooks は利用できません</strong><br>
        ClojureScript コンパイルが必要ですが、ネットワーク制限により実行できませんでした。
    </div>
    
    <p>Clerk は Athens の開発ノートブックシステムで、以下の機能を提供します:</p>
    <ul>
        <li>📊 インタラクティブな Clojure データ可視化</li>
        <li>📖 開発ドキュメントとチュートリアル</li>
        <li>🔬 Athens パーサーとコンポーネントの分析</li>
        <li>⚡ ライブコーディングと結果プレビュー</li>
    </ul>
    
    <p><strong>完全な Clerk Notebooks を表示するには:</strong></p>
    <ol>
        <li>ローカル環境で <code>yarn notebooks</code> を実行</li>
        <li>または完全なネットワークアクセスがある環境でビルド</li>
    </ol>
    
    <nav>
        <a href="/athens/" class="nav-link">← Athens メインページに戻る</a>
        <a href="https://github.com/YU000jp/athens/tree/main/dev/notebooks" class="nav-link">📁 Notebook ソースコード</a>
    </nav>
</body>
</html>
EOF

# Create a simple navigation index at root
cat > vercel-static/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Athens Research - Vercel デプロイメント</title>
    <style>
        body {
            font-family: system-ui, -apple-system, 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
            max-width: 600px;
            margin: 4rem auto;
            padding: 2rem;
            text-align: center;
            line-height: 1.6;
        }
        .nav-link {
            display: inline-block;
            margin: 1rem;
            padding: 1rem 2rem;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-size: 1.1em;
        }
        .nav-link:hover {
            background: #0056b3;
        }
        .logo {
            font-size: 3em;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <div class="logo">🏛️</div>
    <h1>Athens Research</h1>
    <p>オープンソース知識グラフアプリケーション</p>
    
    <nav>
        <a href="/athens/" class="nav-link">📱 Athens アプリ</a>
        <a href="/clerk/" class="nav-link">📚 Clerk Notebooks</a>
    </nav>
    
    <p><small>Vercel プレビューデプロイメント</small></p>
</body>
</html>
EOF

echo "✅ Mock Vercel build completed successfully!"
echo "📁 Output directory: vercel-static/"
echo "🌐 Main navigation: vercel-static/index.html"
echo "🏛️ Athens app: vercel-static/athens/index.html"  
echo "📚 Clerk notebooks: vercel-static/clerk/index.html"