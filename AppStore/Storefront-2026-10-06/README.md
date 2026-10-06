# 生活ボードカウント — App Store登録準備

制作日: 2026-10-06 / 日本語 / iPhoneのみ。**未登録・未アップロード**。

## 登録用ファイル

- [サブタイトル](subtitle.txt)
- [プロモーション用テキスト](promotional-text.txt)
- [説明全文](description.txt)
- [検索キーワード](keywords.txt)
- [3枚の一覧プレビュー](preview.png)

登録順は次のとおり。`images/`の3枚だけが登録用であり、`raw/`・`evidence/`・
一覧プレビューは登録しない。

1. [できたら、ひと押し](images/01-today.png)
2. [7日間を親子で振り返る](images/02-history.png)
3. [家族の「できた」を追加](images/03-add-item.png)

登録先: App Store Connect → 生活ボードカウント（App ID `6794626819`）→
対象iOSバージョン → 日本語 → iPhone **6.9インチ**。
3枚とも縦 **1320 × 2868 px / RGB PNG / アルファチャンネルなし**。
6.5インチ枠にそのまま入れない。実際の登録画面で枠・並び順・自動縮小先を再確認する。

## 原稿の意図と実装照合

保護者が用途を判断できるよう、回数記録・親子の振り返り・身近な行動例を先に伝える。
初回は見本の「できた！」を1回押す操作まで案内する。

| 訴求 | 照合先・扱い |
| --- | --- |
| 項目ごとの1回追加と今日の合計 | `TodayCountView` / `CountStore.increment` / `total` |
| 「もどす」で1回取消 | 同画面の取消ボタン / `CountStore.decrement`。0未満にはならない |
| 今日を含む直近7日間 | `HistoryView` / `CalendarHelper.recentDaysNewestFirst`。7日分すべてが1画面に収まるという意味ではない |
| 名前・絵文字で追加 | 今日の＋ → `CountItemEditorView(mode: .add)` →「ほぞん」 |
| 初回の見本 | 保存キーがない初回のみ。正常な0件や読込失敗時に見本が復活するとは説明しない |
| 端末内保存・ログイン等なし | `CountStore`、アプリ構成、シリーズ方針と一致 |

既存項目の編集・削除、設定、親ゲート、同期、ランキング、復旧保証は訴求しない。
習慣定着や行動改善、検索順位・利用開始数の改善は保証しない。
キーワードは用途に基づく仮説であり、検索需要の測定結果ではない。
10月4日のシリーズ案を基本に、検索キーワードは「習慣」を外し「親子・子育て・幼児」を
加え、行動例と利用者に寄せた。正式名・サブタイトルとの同語重複は避けた。

## 公開状態とソースの保全

- 開始時、対象アプリとシリーズ管理リポジトリを別々に確認。双方未コミット変更なし。
  `pull --ff-only`は双方「Already up to date」。既存コミットの書換えなし。
- 撮影元: `29144f68e24626392ad2816b642927abdf696016`。
  リリース準備コミット`2cf7ac3`との差分は、アプリ本体とXcodeプロジェクトについて空。
- [Apple公開APIの取得結果](evidence/apple-lookup.json)で2026-10-06に正式名とVersion 1.0.1を確認。
  公開日時は2026-09-10 00:12:21 JST。APIからBuild番号・審査画面の状態は断定しない。
- 今回App Store Connectの編集画面には入力していない。最新のキーワード・
  編集可否・審査状態は未確認。過去のConnect確認はシリーズ資料の2026-10-04時点。
- 保存形式、保存キー、項目・記録ID、日付キー、正常0件、読込失敗時の原本保護、
  Bundle ID、署名、Version/Buildは変更していない。実機には接続・書込みしていない。
- 参照: `docs/RELEASE_1.0.1.md` / `docs/DATA_PROTECTION.md`（アプリルートから）。
  アプリ実装・既存テスト・他アプリ・シリーズ共通文書の変更はない。

## 合成データと撮影方法

新規の専用Simulator `Count-Storefront-20261006`
（iPhone 17 Pro Max / iOS 26.5、UDID `F1A5AE3D-C771-40DB-92A9-46D44AFBD0CA`）だけを使用。
ユーザーの氏名・写真・実機記録を使わない。

リポジトリのHEADを一時ディレクトリへexportし、本番コードはそのままビルドする。
一時コピーのテストファイルだけを[見本作成用](production/StorefrontSeedTests.swift)と
[撮影用](production/StorefrontCaptureTests.swift)に置き換える。
これらは通常のXcodeプロジェクトには組み込まれていない。

1. 本番の初回起動で見本5項目を作成。
2. 本番`moveItems`ではみがき・ふくをきれたを先頭へ移す。
3. 本番`CalendarHelper`で今日から6日前までの日付を求め、本番`CountStore.increment(on:)`
   を必要回数呼び出す。日付キーや保存JSONを直接生成・編集しない。
   これは「できた！」ボタンが呼ぶ同じ処理をテストから実行したものであり、
   7日分を手動タップしたという意味ではない。時計・日付は変更しない。
4. 追加→取消と再読み込みで回数保持を検証。専用環境以外、既存記録あり、異常読込の場合は停止する。
5. 通常起動の日本語UIから「きょう」→「きろく」→＋で撮影。
   項目追加は実際の入力欄へ「おかたづけ」「🧸」を入力し、Returnでキーボードを閉じる。
   「ほぞん」の有効性・操作可能性を確認し、撮影後に実際に保存して追加を検証する。
6. ステータスバーは専用Simulatorの表示オーバーライドで9:41、Wi-Fi、電池100%。
   アプリの日付・記録数は元の画面表示のまま。
7. 画面全体を縦横比を維持して縮小し、クリーム色の外枠・見出し・補足を画面の外へ配置。
   UIの塗り替え・回数の加工・複数画面のつぎはぎ・写真による架空端末の生成は行わない。

作成・再読み込み検証済みの見本の記録（今日=2026-10-06）:

| 日付 | はみがき | ふくをきれた | 合計 |
| --- | ---: | ---: | ---: |
| 10/6 | 2 | 1 | 3 |
| 10/5 | 1 | 1 | 2 |
| 10/4 | 2 | 1 | 3 |
| 10/3 | 1 | 0 | 1 |
| 10/2 | 2 | 1 | 3 |
| 10/1 | 1 | 1 | 2 |
| 9/30 | 1 | 0 | 1 |

## 検証結果

2026-10-06 / Xcode 26.6（17F113）/ iOS 26.5 Simulator。

| 確認 | 結果 |
| --- | --- |
| サブタイトル | 15文字 / 上限30文字 |
| プロモーション文 | 69文字 / 上限170文字 |
| 説明 | 624文字 / 上限4000文字（末尾改行を除く） |
| キーワード | 30文字・UTF-8 76バイト / 100文字・100バイト以下 |
| 登録画像3枚 | 1320×2868、RGB PNG、アルファなし。sipsで実ファイルを確認 |
| 文字切れ | レンダラーの文字領域チェック成功。完成画像と3枚一覧を目視確認し、見出し・補足・主要操作に切れなし |
| 縮小時 | 一覧の各画像420px幅（内部の実画面約344px幅）でも、見出し・はみがき・ふくをきれた・1/2回・できた！・もどす・ほぞんを識別可能 |
| 今日 | はみがき2回、ふくをきれた1回、合計3回。画面と[合成データ](evidence/synthetic-state.json)が一致 |
| 7日間 | 今日3回・昨日2回・10/4の3回が画像内に表示。7日分の保存値を検証し、[さらに前の日もスクロールして撮影](evidence/history-older-days.png) |
| 追加 | 名前「おかたづけ」、絵文字🧸。キーボード非表示と「ほぞん」有効・タップ可能を自動確認。撮影後の[保存結果](evidence/added-item-verification.png)も確認 |
| ライト／ダーク | 登録用3枚はライト指定。OSダーク指定で[今日](evidence/today-dark-verification.png)・[記録](evidence/history-dark-verification.png)も撮影・目視確認。アプリ既存の明るい配色はそのまま |
| 合成記録作成 | [1件成功](evidence/seed-test-summary.json)。本番記録操作、追加→取消、再読み込み保持 |
| 既存の記録保護・回帰テスト | 単体23件成功。初回・0件・異常形式・原本保護・互換性・操作等。[結果](evidence/capture-and-unit-test-summary.json) |
| 撮影UIテスト | 上記と合わせ24件成功（単体23＋撮影1）。3画面・キーボード非表示・保存を確認 |
| 既存の復旧UIテスト | [3件成功](evidence/recovery-ui-test-summary.json)。ライト／ダークの自動アクセシビリティ監査・最大文字・確認キャンセルを含む。通常画面全体のアクセシビリティ合格を意味しない |
| ビルド | 対象リポジトリのgeneric iOS Simulator向けDebugで `BUILD SUCCEEDED`。ソース無変更 |
| 境界 | 他アプリ・本番コード・既存テスト・保存仕様・識別子・署名・実機は変更なし。push・Connect保存・アップロード・新Version・提出・公開なし |

初回の撮影テストでは、改行入力の直後にキーボードが存在するという判定が残り失敗。
撮影手順を、必要時は画面上のReturnキーを押し、非表示まで待つ形に改善して再撮影し成功した。
アプリ本体へキーボード処理や撮影用コードを加えていない。
初回Simulator起動では初期移行の失敗表示・長い待機があったが、その後のアプリ起動、
合成データ作成、撮影、上記テストは完了した。

一時的な詳細結果は `/private/tmp/count-storefront-seed.xcresult`、
`/private/tmp/count-storefront-capture2.xcresult`（既存復旧UI3件）、
`/private/tmp/count-storefront-capture3.xcresult`（既存単体23件＋撮影1件）。
一時領域は将来削除され得るため、合成データ・画像・要約を本フォルダに保存した。
ビルド結果は[検証記録](evidence/verification.md)を参照。

## 再制作

新しい空の専用Simulatorを使う。既存の実機・通常Simulatorに対して初期化や
保存値の差し替えを行わない。スクリプトには指定Simulator名のガードがある。
再実行時は新規環境を用意し、既存環境の記録を消して使い回さない。

```sh
# このアプリのHEADをmktempで作った一時ディレクトリにgit archiveで展開する。
# production/StorefrontSeedTests.swift を一時コピーの
# SeikatsuBoardCountTests/CountStoreTests.swift にコピー。
# production/StorefrontCaptureTests.swift を一時コピーの
# SeikatsuBoardCountUITests/RecoveryUITests.swift にコピー。
# 対象名の新規専用Simulatorを作成して起動する。
xcodebuild test -project SeikatsuBoardCount.xcodeproj -scheme SeikatsuBoardCount \
  -destination 'platform=iOS Simulator,id=<専用SimulatorのUDID>' \
  -parallel-testing-enabled NO -derivedDataPath <一時DerivedData> \
  -resultBundlePath <seed.xcresult> -only-testing:SeikatsuBoardCountTests CODE_SIGNING_ALLOWED=NO
xcodebuild test -project SeikatsuBoardCount.xcodeproj -scheme SeikatsuBoardCount \
  -destination 'platform=iOS Simulator,id=<専用SimulatorのUDID>' \
  -parallel-testing-enabled NO -derivedDataPath <一時DerivedData> \
  -resultBundlePath <capture.xcresult> -only-testing:SeikatsuBoardCountUITests CODE_SIGNING_ALLOWED=NO
# xcresulttool export attachmentsで撮影添付を出力し、元画像をraw/へコピーする。
swift production/render.swift <この制作フォルダの絶対パス>
```

## 公開へ進める場合の残作業

1. 原稿と3枚の画像をユーザーが確認する。
2. 別途許可を得てGitHubへpushする（今回未実施）。
3. App Store Connectで最新の状態・日本語欄・6.9インチ枠・既存画像の置換範囲を確認する。
4. サブタイトル・説明・画像等は次回バージョンに合わせて登録し、必要なビルド・審査手順を確認する。
   採番・新Version作成・ビルド配布・保存・審査提出・公開にはそれぞれ別途の許可が必要。
   プロモーション文は新Versionなしで更新可能だが、今回は保存しない。
5. 配信時は登録画像の並び順・全端末への縮小表示・公開ページの内容を確認する。

実機更新、App Store版からの更新、過去記録ありの実機更新、TestFlight実機、
実機VoiceOver音声・読み順は今回未確認。検索流入や利用開始への効果も未計測。

## 参照資料

- シリーズ: `AGENTS.md`、`docs/storefront/STORE_IMPROVEMENT_2026-10-04.md`、
  `docs/storefront/count.md`、開発ガイド・シリーズ方針・現状資料・リリースガイド。
- [Appleの画像寸法・ファイル要件](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
  （2026-10-06確認）。6.9インチの1320×2868、透過なしに一致させる。
- [Appleの製品ページ作成案内](https://developer.apple.com/app-store/product-page/)
  （2026-10-06確認）。サブタイトル30文字、プロモーション文170文字、キーワード100文字。
  キーワードはさらにUTF-8で100バイト以下に収める。実際の入力時にも検証する。
- [公開ページ](https://apps.apple.com/jp/app/id6794626819)
