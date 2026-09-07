# 生活ボードカウント

`生活ボードカウント` は、3〜8歳くらいの子どもが「できた！」を押して日々の行動を記録する、親子向けのローカル完結 iOS アプリです。

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
- `きょう` タブ右上の `＋` から、子どもが使う画面のまま項目追加
- `きょう` タブのカードをドラッグして並び替え

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
