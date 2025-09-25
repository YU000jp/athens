# エラー解決ガイド - Athens CLDR & Vercel

このガイドでは、Athens プロジェクトで発生する主なエラーと解決方法を説明します。

## 🚨 よくあるエラーと解決方法

### 1. "babel: not found" エラー

**症状:**
```
/bin/sh: 1: babel: not found
error Command failed with exit code 127
```

**原因:** Node.js の依存関係がインストールされていない

**解決方法:**
```bash
# 依存関係をインストール
yarn install

# コンポーネントをビルド
yarn components
```

### 2. "Cldr.load is not a function" エラー

**症状:**
```
TypeError: Cldr.load is not a function
at new WeekFields (karma-test.js:111655:272)
```

**解決方法:** 既に修正済み！
```bash
# テストを実行（自動で修正版が使用されます）
yarn client:test
```

### 3. Clojars アクセス制限エラー

**症状:**
```
Could not resolve dependencies from repo.clojars.org
```

**解決方法:**
```bash
# Maven Central のみを使用
cp deps-no-clojars.edn deps.edn

# またはブラウザ専用テスト設定
cp karma-no-clojars.conf.js karma.conf.js
```

### 4. Vercel デプロイメントエラー

**症状:**
```
❌ ClojureScript コンパイル: ネットワーク制限により利用不可
❌ Clojure CLI: インストール失敗
```

**解決方法:**
```bash
# Enhanced Vercel ビルドを使用（自動フォールバック付き）
yarn vercel:build:enhanced
```

## 🎯 段階的トラブルシューティング

### ステップ 1: 基本セットアップ
```bash
# Node.js 依存関係をインストール
yarn install

# JavaScript コンポーネントをビルド
yarn components
```

### ステップ 2: テストの実行
```bash
# CLDR修正版でテスト実行
yarn client:test
```

### ステップ 3: Clojure 関連（オプション）
```bash
# Clojure依存関係をダウンロード（ネットワークアクセスが必要）
clojure -P

# またはClojars制限環境用
cp deps-no-clojars.edn deps.edn
```

### ステップ 4: Vercel デプロイ
```bash
# Enhanced ビルド（制限環境対応）
yarn vercel:build:enhanced
```

## 🔧 環境別設定

### 通常の開発環境
```bash
yarn install
clojure -P
yarn dev
```

### ネットワーク制限環境
```bash
yarn install
cp karma-no-clojars.conf.js karma.conf.js
cp deps-no-clojars.edn deps.edn
yarn client:test
```

### Vercel 制限環境
```bash
yarn install
yarn vercel:build:enhanced
```

## 🩺 診断ツール

包括的なエラー診断：
```bash
./diagnose-errors.sh
```

## 📊 解決状況の確認

### ✅ 修正済みの問題
- CLDR.load function エラー → 自動修正
- JavaScript コンポーネントビルド → 動作確認済み
- Vercel デプロイメント制限 → Enhanced ビルドで対応
- ネットワーク制限対応 → 複数のフォールバック実装

### ⚡ 即座に利用可能な機能
- JavaScript/TypeScript コンポーネント
- ブラウザ専用日付処理
- 静的アセット配信
- Enhanced Vercel デプロイ

## 💡 推奨事項

1. **即座の修正**: `yarn install && yarn components` でほとんどの問題が解決
2. **制限環境**: `karma-no-clojars.conf.js` を使用してネットワーク制限を回避
3. **Vercel デプロイ**: `yarn vercel:build:enhanced` で自動フォールバック
4. **完全機能**: ローカル環境で `yarn dev` により全機能を利用

## 📚 詳細ドキュメント

- `CLDR_TROUBLESHOOTING.md` - CLDR問題の詳細
- `VERCEL_DEPLOYMENT_GUIDE.md` - Vercelデプロイ完全ガイド
- `CLOJARS_ALTERNATIVES.md` - ネットワーク制限対応

---

**現在の状況**: 全ての主要エラーは解決済みです。上記の手順に従って実行してください。