# 検証記録（2026-10-06）

対象: 生活ボードカウントのみ。開始HEAD: `29144f68e24626392ad2816b642927abdf696016`。

## ビルド

本来の対象リポジトリで次を実行し、終了コード0・`BUILD SUCCEEDED`を確認。

```sh
xcodebuild build -project SeikatsuBoardCount.xcodeproj -scheme SeikatsuBoardCount \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/count-storefront-validation CODE_SIGNING_ALLOWED=NO
```

ログ: `/private/tmp/count-storefront-validation-build.log`（一時ファイル）。
撮影元は本番ソースが同一の一時export。公開版とのソース照合:

```sh
git diff 2cf7ac3 29144f6 -- SeikatsuBoardCount SeikatsuBoardCount.xcodeproj
```

差分なし。公開ストアのバイナリとビット単位で比較したという意味ではない。

## テストと画面

- 合成記録作成1件: 0失敗・0スキップ。
- 既存の単体23件＋撮影UI1件: 24成功・0失敗・0スキップ。
- 既存の復旧UI3件: 3成功・0失敗・0スキップ。
- 撮影用の初回UIテストにはキーボード判定の失敗が1回あり、待機を含む操作手順を修正後に成功。
- 完成画像・一覧プレビュー・追加結果・OSダーク指定画像・古い日付の記録画像を目視確認。
- 3枚は実画面全体を同じ縦横比で縮小。画像内部の回数・項目名・表示要素は加工していない。
- `production/render.swift`が文字数制限と見出し描画領域を検査。
  `sips -g pixelWidth -g pixelHeight -g hasAlpha images/*.png`は全件1320×2868・hasAlpha:no。
- [checksums.sha256](checksums.sha256)に元画像・完成画像・プレビュー・合成データのハッシュを保存。

## 未確認・今回行っていないこと

- 実機更新、App Store版からの更新、過去記録ありの実機更新、TestFlight実機。
- 実機VoiceOver音声・読み順。既存復旧UIの自動監査は実機VoiceOverを代替しない。
- 通常画面全体の自動アクセシビリティ監査・全Dynamic Typeサイズ。
- 登録画像の実際のConnect入力検証・ストア各端末での自動縮小結果。
- Connectの最新編集可否・キーワード等。10/4のシリーズ確認記録と10/6の公開APIは区別する。
- 検索表示回数・入手率・利用開始率の改善効果。
- GitHubへのpush、Apple側の保存・アップロード・新Version・審査提出・公開。

アプリ本体の追加修正は今回の制作に必要なかった。素材制作のためのコード変更は提案しない。
