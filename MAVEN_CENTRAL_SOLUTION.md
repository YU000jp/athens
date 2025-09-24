# Athens 依存関係解決：Maven Central 優先化の実装

## 問題の概要
- **問題**: `repo.clojars.org` へのネットワークアクセスが制限されている
- **解決策**: Maven Central を優先し、Clojars 依存関係の代替手法を提供

## 実装された変更

### 1. リポジトリ優先順位設定 (`deps.edn`)
```clojure
:mvn/repos
{"central"   {:url "https://repo1.maven.org/maven2/"}          ; 最高優先度
 "sonatype"  {:url "https://oss.sonatype.org/content/repositories/public/"}
 "clojars"   {:url "https://repo.clojars.org/"}}              ; アクセス可能時のフォールバック
```

**効果**: 
- Maven Central が最初に試行される
- Clojars への依存を可能な限り減らす
- 既存の機能を維持

### 2. 依存関係事前キャッシュスクリプト
新しいスクリプト: `script/pre-cache-deps.sh`

**使用方法**:
```bash
# 依存関係を事前ダウンロード（ネットワークアクセス可能時）
./script/pre-cache-deps.sh

# または yarn コマンドで
yarn deps:cache

# 後でキャッシュされた依存関係を使用してビルド
yarn prod
```

**機能**:
- Clojars アクセス可能性を自動検出
- Maven Central のみアクセス可能な場合の部分キャッシング
- キャッシュ状況のレポート

### 3. 包括的ドキュメント更新
`BUILD_TROUBLESHOOTING.md` を更新：
- 依存関係のソース別分類
- 複数の解決策オプション
- ネットワーク診断コマンド
- 段階的解決手順

## 技術的詳細

### 依存関係の分類
**Maven Central で利用可能**:
- コア Clojure ライブラリ (`org.clojure/*`)
- 標準的な Java エコシステムライブラリ
- 一部の広く使用される Clojure ライブラリ

**Clojars 専用依存関係**:
- `metosin/reitit` - HTTP ルーティングライブラリ
- `metosin/muuntaja` - データ形式変換
- `metosin/komponentit` - UI コンポーネントユーティリティ
- `denistakeda/posh` - DataScript 統合
- `datascript-transit/datascript-transit` - DataScript シリアライゼーション

### リポジトリ優先順位の仕組み
1. **Maven Central** を最初に試行
2. **Sonatype** リポジトリを次に試行
3. **Clojars** をフォールバックとして使用

これにより、可能な限り制限の少ないリポジトリから依存関係を取得します。

## 使用シナリオ

### シナリオ 1: フル ネットワーク アクセス
```bash
# 通常のビルドプロセス
yarn install
clojure -P          # 全ての依存関係を取得
yarn prod           # プロダクションビルド
```

### シナリオ 2: Clojars 制限環境
```bash
# 事前に別環境で依存関係をキャッシュ
./script/pre-cache-deps.sh

# 制限環境でキャッシュを使用
yarn install
clojure -P          # キャッシュされた依存関係を使用
yarn prod           # ビルド実行
```

### シナリオ 3: CI/CD 環境
GitHub Actions や他の CI 環境で：
```yaml
- name: Pre-cache dependencies
  run: ./script/pre-cache-deps.sh
  
- name: Build with cached dependencies  
  run: yarn prod
```

## 互換性保証
- 既存のビルドプロセスは変更なし
- 既存のスクリプトはそのまま動作
- 新機能は段階的に利用可能

## 検証方法
```bash
# ネットワーク接続テスト
curl -I https://repo1.maven.org/maven2/        # 動作するはず
curl -I https://repo.clojars.org/               # ブロックされる可能性
curl -I https://oss.sonatype.org/content/repositories/public/  # 動作するはず

# 依存関係解決テスト
clojure -P

# 完全ビルドテスト
yarn components
yarn prod

# キャッシュ確認
ls -la ~/.m2/repository/
```

## まとめ
この実装により、Athens プロジェクトは Maven Central を優先的に使用し、Clojars アクセスが制限された環境でも可能な限りビルドが実行できるようになりました。事前キャッシュ機能により、完全にオフライン環境でのビルドも可能です。