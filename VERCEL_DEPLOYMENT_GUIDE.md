# Vercel デプロイメント問題解決ガイド

このガイドは、Athens を Vercel にデプロイする際の問題と解決策を日本語で詳しく説明します。

## 🚨 よくある Vercel デプロイメントエラー

### 1. ClojureScript コンパイルエラー

**症状:**
```
❌ ClojureScript コンパイル: ネットワーク制限により利用不可
❌ Clojure CLI: インストール失敗
❌ 外部依存関係: Clojars アクセス不可
```

**原因:**
- Vercel の制限されたネットワーク環境
- `repo.clojars.org` へのアクセスブロック
- Clojure CLI のインストール制限

**解決策:**

#### 即座の解決（推奨）
```bash
# Enhanced Vercel 設定を使用
yarn vercel:install:enhanced
yarn vercel:build:enhanced
```

これにより、以下の機能が有効になります：
- ✅ JavaScript/TypeScript コンポーネントのビルド
- ✅ 静的アセットの配信
- ✅ ブラウザ専用日付処理
- ✅ 包括的エラー処理とフォールバック

### 2. 依存関係解決エラー

**症状:**
```
Error: Failed to download dependencies from repo.clojars.org
Error: Clojure CLI installation timeout
```

**解決策:**

#### オプション A: Maven Central のみ使用
```bash
# Maven Central 専用設定を使用
cp deps-no-clojars.edn deps.edn
```

#### オプション B: 事前ビルド済みアーティファクトの使用
```bash
# GitHub Actions で事前ビルドしてから Vercel にデプロイ
# .github/workflows/vercel-deploy.yml を参照
```

### 3. ビルドタイムアウトエラー

**症状:**
```
Error: Build exceeded maximum time limit
Error: Process killed due to timeout
```

**解決策:**
- **静的ビルドモード**を使用：
  ```bash
  export ATHENS_BUILD_MODE="static"
  yarn vercel:build
  ```

## 🎯 Vercel 設定の最適化

### 1. vercel.json の設定

```json
{
  "version": 2,
  "buildCommand": "yarn vercel:build:enhanced",
  "outputDirectory": "vercel-static",
  "installCommand": "yarn vercel:install:enhanced",
  "build": {
    "env": {
      "NODE_VERSION": "20",
      "ATHENS_BUILD_MODE": "static",
      "JAVA_TOOL_OPTIONS": "-Xmx1g"
    }
  }
}
```

### 2. package.json スクリプトの設定

```json
{
  "scripts": {
    "vercel:install:enhanced": "./vercel-enhanced-setup.sh && yarn",
    "vercel:build:enhanced": "./vercel-enhanced-build.sh",
    "vercel:build:static": "yarn components && ./create-static-build.sh"
  }
}
```

## 🔧 ビルドモード別対応策

### モード 1: 静的ビルド（推奨）
- **対象:** 全ての制限環境
- **機能:** JavaScript コンポーネント + 静的コンテンツ
- **設定:** `ATHENS_BUILD_MODE="static"`

**利点:**
- ✅ 確実にビルド成功
- ✅ 高速ビルド（5-10分）
- ✅ ネットワーク制限に影響されない
- ✅ 基本的な Athens 機能を提供

**制限:**
- ❌ 動的 ClojureScript 機能なし
- ❌ Clerk Notebooks の静的生成なし

### モード 2: 部分ビルド
- **対象:** Maven Central アクセス可能環境
- **機能:** JavaScript + 限定的 Clojure 機能
- **設定:** `ATHENS_BUILD_MODE="partial"`

### モード 3: フルビルド
- **対象:** 全ネットワークアクセス可能環境
- **機能:** 完全な Athens アプリケーション
- **設定:** `ATHENS_BUILD_MODE="full"`

## 🌐 代替デプロイ戦略

### 戦略 1: GitHub Actions + Vercel

```yaml
# .github/workflows/vercel-deploy.yml
name: Vercel Deployment
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        distribution: 'temurin'
        java-version: '17'
    
    # 完全な環境でビルド
    - name: Install Clojure CLI
      run: |
        curl -O https://download.clojure.org/install/linux-install.sh
        chmod +x linux-install.sh
        ./linux-install.sh
    
    - name: Build Athens
      run: |
        yarn install
        clojure -P
        yarn prod
        yarn notebooks:static
    
    # Vercel にデプロイ
    - name: Deploy to Vercel
      uses: vercel/action@v2
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-args: '--prod'
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
```

### 戦略 2: Docker + Vercel

```dockerfile
# Dockerfile.vercel
FROM clojure:temurin-17-alpine

# 完全な Clojure 環境をセットアップ
RUN apk add --no-cache nodejs yarn
WORKDIR /app
COPY . .
RUN yarn install && clojure -P && yarn prod

# 静的ファイルのみを Vercel に送信
FROM scratch as export-stage
COPY --from=0 /app/resources/public /
```

### 戦略 3: 事前ビルド + CDN

1. **ローカルまたは CI でフルビルド**
2. **静的アセットを CDN にアップロード**
3. **Vercel では軽量版をホスト**

## 🎨 カスタム静的ページの作成

制限環境用の高品質な静的ページ：

```html
<!-- vercel-static/athens/index.html -->
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>Athens Research - 知識グラフアプリケーション</title>
    <!-- Athens ブランディングとスタイル -->
</head>
<body>
    <!-- 完全な Athens UI モックアップ -->
    <!-- JavaScript コンポーネントのプレビュー -->
    <!-- ドキュメントとリソースへのリンク -->
</body>
</html>
```

## 📊 パフォーマンス最適化

### ビルド時間短縮
- **並列処理:** JavaScript と CSS を並行ビルド
- **キャッシュ活用:** `node_modules` と Clojure dependencies のキャッシュ
- **段階的ビルド:** 必要最小限の機能から段階的に拡張

### 結果サイズ最適化
- **Tree Shaking:** 未使用 JavaScript コードの除去
- **画像最適化:** WebP 変換と適切なサイズ調整
- **CSS 最小化:** 不要なスタイルの除去

## 🔍 デバッグとトラブルシューティング

### ログ分析
```bash
# Vercel ビルドログの確認方法
vercel logs <deployment-url>

# ローカルでのVercel環境模擬
vercel dev --debug
```

### 段階的デバッグ
```bash
# 1. JavaScript コンポーネントのみテスト
yarn components

# 2. 静的ビルドテスト
./vercel-enhanced-build.sh

# 3. Vercel ローカル環境テスト
vercel dev
```

## 🎯 最終的な推奨事項

### 短期的解決（即座に実装可能）
1. **静的ビルドモード**を使用
2. **Enhanced Vercel スクリプト**を適用
3. **ブラウザ専用日付処理**を有効化

### 中長期的解決（将来的に実装）
1. **GitHub Actions 統合**による事前ビルド
2. **CDN 配信**による高速化
3. **Docker コンテナ**による環境統一

### 完全な Athens 体験のために
- **ローカル開発環境**のセットアップを推奨
- **詳細ドキュメント**による学習とカスタマイズ
- **コミュニティ**との連携による継続的改善

## 📚 関連リソース

- [Athens README.md](https://github.com/YU000jp/athens/blob/main/README.md) - 基本セットアップ
- [CLOJARS_ALTERNATIVES.md](https://github.com/YU000jp/athens/blob/main/CLOJARS_ALTERNATIVES.md) - 制限環境対応
- [BUILD_TROUBLESHOOTING.md](https://github.com/YU000jp/athens/blob/main/BUILD_TROUBLESHOOTING.md) - 一般的ビルド問題
- [Vercel Documentation](https://vercel.com/docs) - Vercel 公式ドキュメント

---

このガイドにより、Vercel デプロイメントの問題を段階的に解決し、Athens の機能を最大限活用できるようになります。