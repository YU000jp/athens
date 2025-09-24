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
- Clojure CLI
- Yarn

### セットアップ

```bash
# 依存関係のインストール
yarn install
clojure -P

# JavaScript コンポーネントのビルド
yarn components

# Vercel ビルドのテスト（ローカル）
yarn vercel:build
```

### モック ビルドでのテスト

ネットワーク接続の問題がある場合は、モック ビルドを使用できます：

```bash
./mock-vercel-build.sh
```

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
   # 依存関係の再インストール
   clojure -P
   ```

2. **JavaScript コンポーネントのビルドエラー**
   ```bash
   # コンポーネントの再ビルド
   yarn components
   ```

3. **ネットワーク接続の問題**
   ```bash
   # モック ビルドを使用
   ./mock-vercel-build.sh
   ```

### ログの確認

- Vercel ダッシュボードでビルドログを確認
- GitHub Actions タブでワークフローログを確認

## 参考リンク

- [Vercel Documentation](https://vercel.com/docs)
- [Athens ADR 0011: Components Preview](doc/adr/0011-components-preview.md)
- [GitHub Actions Build Workflow](.github/workflows/build.yml)