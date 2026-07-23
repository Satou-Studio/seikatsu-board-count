# 生活ボード カウント

`生活ボード カウント` は、3〜8歳くらいの子どもが「できた！」を押して日々の行動を記録する、親子向けのローカル完結 iOS アプリです。

## 概要

- SwiftUI
- iOS 17 以上
- 通信なし
- UserDefaults + Codable によるローカル保存
- SwiftData / 外部ライブラリなし
- 生活ボードシリーズに合わせた薄いクリーム背景、白いカード、大きなボタンの UI

## 主な機能

- `きょう`: 今日の「できた！」回数を項目ごとに記録
- `きろく`: 直近7日分の回数を項目ごとに表示
- `せってい`: 親向けの簡易ロック後に、項目の追加・編集・削除・並び替え
- `きょう` タブ右上の `＋` から、子どもが使う画面のまま項目追加

## 初期項目

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
