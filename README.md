# 生活ボードカウント

`生活ボードカウント` は、3〜8歳くらいの子どもが「できた！」を押して日々の行動を記録する、親子向けのローカル完結 iOS アプリです。

## 公開状況

[App Store](https://apps.apple.com/jp/app/id6794626819)で **Version 1.0.2** を公開済みです。
公開日時は2026-10-09 22:53:11 JST、最新の公開確認日は2026-10-11です。
紹介文と画像3枚（今日→記録→追加）を更新しました。機能・保存形式は変更していません。
Build 3は提出準備記録に基づき、公開APIでは確認できません。
公開確認の根拠と未確認の実機試験は[最新リリース記録](docs/RELEASE_1.0.2.md)を参照してください。
以前の記録保護改善は[1.0.1の記録](docs/RELEASE_1.0.1.md)に残しています。

## 概要

- SwiftUI
- iOS 17 以上
- 回数の記録・確認は通信なし。保護者が任意で開く公式サイト／レビューには外部アプリ・通信を使用
- UserDefaults + Codable によるローカル保存
- SwiftData / 外部ライブラリなし
- 生活ボードシリーズに合わせた薄いクリーム背景、白いカード、大きなボタンの UI

## 主な機能

- `きょう`: 今日の「できた！」回数を項目ごとに記録
- `きろく`: 直近7日分の回数を項目ごとに表示
- `きょう` タブ右上の `＋` から、子どもが使う画面のまま項目追加
- `きょう` タブのカードをドラッグして並び替え
- 一覧末尾と復旧画面の「保護者の方へ」から、任意のApp Storeレビューと公式サイトの使い方・お問い合わせへ進む（次回公開向け実装。公開1.0.2には未反映）

## 任意のご意見・レビュー

レビュー入口はApp ID 6794626819の投稿画面を直接開きます。問い合わせは公式サイトへ集約します。
アプリ内のメール作成・宛先・件名・本文例・メール不可時の案内は削除しました。
記録や端末情報の自動送信、自動レビュー依頼、満足度による誘導、親ゲート、設定タブは追加しません。
既存Archive／TestFlight Build 4〜6にはこの削除が含まれず、最終提出対象にはできません。
仕様・検証の限界・次回公開に必要な作業は[補助画面の記録](docs/PARENT_FEEDBACK.md)を参照してください。

## 初期項目

見本は保存データがない初回だけ作成します。正常な0件状態は次回起動でも維持します。
読み込めない記録がある場合は上書きせず、再読み込みと、控えを残した再開の案内を表示します。
保存互換性・復旧の制限・検証方法は [記録の保護と検証](docs/DATA_PROTECTION.md) を参照してください。

- 🚽 トイレ
- 🪥 はみがき
- 👕 ふくをきれた
- 🍚 ごはん
- ⭐️ おてつだい

## プロジェクト

Xcode で以下を開きます。

```text
SeikatsuBoardCount.xcodeproj
```

実行先はシミュレータまたは接続済みの実機 iPhone を選択してください。

## 署名設定

現在の設定:

- Bundle Identifier: `com.saku.seikatsuboardcount`
- Development Team: `4W95W79JT2`
- Signing: Automatic

実機でビルドする場合は、Apple Developer Program のチームに対象 iPhone が登録されている必要があります。未登録の場合、Xcode の `Window > Devices and Simulators` で実機を認識させてから再実行してください。

## ビルド確認

シミュレータ向けビルド:

```sh
xcodebuild build \
  -project SeikatsuBoardCount.xcodeproj \
  -scheme SeikatsuBoardCount \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO
```
