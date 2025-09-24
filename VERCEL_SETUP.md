# Vercel Setup for Athens

このファイルは Athens プロジェクトの Vercel 設定について説明します。

## 概要

Athens は Vercel を使用して以下のコンポーネントをホストできます：
- Athens ウェブクライアント
- Clerk ノートブック (開発者ドキュメント)

## 必要な設定

### 1. Vercel プロジェクト設定

Vercel ダッシュボードで以下の設定を行います：

**Build & Development Settings:**
```
Build Command: yarn vercel:build
Output Directory: vercel-static
Install Command: yarn vercel:install
```

**Environment Variables:**
- `NODE_VERSION`: 20 (推奨)

### 2. GitHub Actions との連携

このプロジェクトは GitHub Actions を通じてデプロイされます：

```yaml
# GitHub Secrets に設定が必要:
VERCEL_TOKEN        # Vercel API トークン
VERCEL_ORG_ID       # Vercel 組織 ID  
VERCEL_PROJECT_ID   # Vercel プロジェクト ID
```

### 3. ブランチ設定

- **Production Branch**: `main`
- **Preview Branches**: feature ブランチから自動デプロイ

## ローカル開発

### 前提条件

- Node.js 20+
- Java 11+
- Clojure CLI (オプション: なくても部分ビルド可能)
- Yarn

### セットアップ

```bash
# 依存関係のインストール
yarn install
clojure -P  # Clojure が利用可能な場合

# JavaScript コンポーネントのビルド
yarn components

# Vercel ビルドのテスト（ローカル）
yarn vercel:build
```

### Vercel ビルドのテスト

```bash
# 完全なテストスイート（サーバー起動含む）
./test-vercel-setup.sh

# ビルドのみテスト
yarn vercel:install
yarn vercel:build
```

### ビルドモード

Athens Vercel ビルドは環境に応じて3つのモードで動作します：

1. **フルビルド** (`full`)
   - Clojure CLI利用可能 + 全依存関係アクセス可能
   - ClojureScript コンパイル + Clerk Notebooks 生成

2. **部分ビルド** (`partial`)
   - Clojure CLI利用可能 + 制限されたネットワーク
   - JavaScript コンポーネントのみ + 基本的な HTML

3. **モックビルド** (`mock`)
   - Clojure CLI不可 または 重度のネットワーク制限
   - プリコンパイル済みコンポーネント + 情報ページ

## ファイル構造

```
vercel-static/           # Vercel 出力ディレクトリ
├── index.html          # メインナビゲーション
├── athens/             # Athens ウェブクライアント
│   └── index.html
└── clerk/              # Clerk ノートブック
    └── index.html
```

## デプロイメント

### 自動デプロイ

- `v2.*` タグがプッシュされると自動的にプロダクション環境にデプロイ
- プルリクエストは自動的にプレビュー環境にデプロイ

### 手動デプロイ

```bash
# Vercel CLI を使用
npx vercel --prod

# または GitHub Actions 経由でタグをプッシュ
git tag v2.1.0
git push origin v2.1.0
```

## トラブルシューティング

### よくある問題

1. **Clojure 依存関係の問題**
   ```bash
   # ローカル環境での依存関係の再インストール
   clojure -P
   ```

2. **JavaScript コンポーネントのビルドエラー**
   ```bash
   # コンポーネントの再ビルド
   yarn components
   ```

3. **ネットワーク接続の問題**
   - **Vercel ビルド環境**: 自動的にフォールバック モードを使用
   - **ローカル開発**: `./test-vercel-setup.sh` でテスト
   - **完全ビルド**: ネットワーク制限のない環境が必要

4. **Vercel デプロイメントの問題**
   - **Clojars アクセス**: `repo.clojars.org` への接続が制限される場合があります
   - **自動フォールバック**: コンポーネントベースの部分ビルドに自動切り替え
   - **プレビュー機能**: 制限された環境でも基本的な機能をプレビュー可能

### ログの確認

- Vercel ダッシュボードでビルドログを確認
- GitHub Actions タブでワークフローログを確認

## 参考リンク

- [Vercel Documentation](https://vercel.com/docs)
- [Athens ADR 0011: Components Preview](doc/adr/0011-components-preview.md)
- [GitHub Actions Build Workflow](.github/workflows/build.yml)