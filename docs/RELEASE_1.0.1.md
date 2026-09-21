# 生活ボードカウント 1.0.1 / Build 2

更新日: 2026-09-21

## 現在の状態：審査承認・公開済み

- 利用者による最終提出後、Appleの審査完了メールでiOS Version 1.0.1の承認を確認した。
  メール受信日時: 2026-09-10 00:09:22 JST。提出ID: `2cada83b-a3f5-4854-b897-715e8bf6aca9`。
- 同メールに記載された提出日時はSep 08, 2026 at 02:01 PM PDT（9月9日06:01 JST）。
- 日本向け[App Store](https://apps.apple.com/jp/app/id6794626819)でVersion 1.0.1を公開済み。
  Apple公開APIの現行版リリース日時は2026-09-09T15:12:21Z（9月10日00:12:21 JST）。
- 9月21日に公開Version 1.0.1、正式名「生活ボードカウント」、記録保護の更新説明を再確認した。
  [公開情報の確認記録](evidence/app-store-public-2026-09-21.json)に公開情報だけを保存した。
- 公開APIはBuild番号を返さない。Build 2は下記のArchive・アップロード・選択保存の記録に基づく。
  公開の確認を、App Storeからの実機インストール・更新試験の完了とは扱わない。
- 最終提出・承認・公開の待ちは解消済み。公開タグは未作成で、シリーズの現状分析に従い、
  App Store版の実機起動と公開バイナリの出所の照合後に確定する。

## 採番と対象

- シリーズ `docs/RELEASE_GUIDE.md` に従い、記録保護の不具合修正をパッチ更新 `1.0.1` とする。
- 9月8日にログイン済みApp Store ConnectのTestFlightで既存は `1.0 / Build 1` のみと確認。次のアップロードを Build 2 とする。
- 保存形式の `schemaVersion: 1` はアプリの公開バージョンとは独立した番号。旧形式の読込互換性を維持する。
- Bundle ID: `com.saku.seikatsuboardcount`、Apple ID: `6794626819`、Team: `4W95W79JT2`。
- Project / Target / Scheme: `SeikatsuBoardCount`。iPhone専用、iOS 17以上を維持。
- ホーム画面・App Store名: `生活ボードカウント`。
- 修正ソース: `e79a25f`。採番・Archive元コミット: `2cf7ac36a6c2e417b209853c51a42c5db98ce0a2`。

## このバージョンの最新情報

記録をより安心して使い続けられるよう、保存データの読み込みを改善しました。

・記録を読み込めない場合に、見本のデータで自動的に上書きしないようにしました。
・すべての項目を削除したあと、再起動しても見本が再び追加されないようにしました。
・読み込みに問題がある場合の案内と、元データの控えを残して空の状態から始める操作を追加しました。
・アプリの表示名を「生活ボードカウント」に統一しました。

## 保存済み審査メモ

This update improves local saved-data protection. No account, login, ads, in-app purchases, or server connection is required. Existing item IDs, daily records, and storage keys are preserved.

If saved data cannot be read, the app keeps the original data unchanged and temporarily disables editing. The user can retry loading, or explicitly confirm starting with an empty state after a local copy of the original value is saved and verified. If that copy cannot be saved, no reset occurs. There is no automatic restoration/import feature for the copy. This error screen is not shown during normal use.

The app remains iPhone-only. The Japanese display name is now 生活ボードカウント. Normal counting and history features are unchanged.

## 検証の区別

- 完了: 単体23件・復旧UI3件、ライト／ダーク自動アクセシビリティ監査、最大文字の操作（9月7日）。
- 完了: 開発用旧版から実機への上書き、項目5件・記録0件の保存値一致（9月8日）。
- 完了: 実機で記録追加、終了・再起動後の保持、取消。利用者が9月8日に確認済み。
- 未確認: App Store配布版からの更新、過去記録ありの実機更新、実際のVoiceOver音声・スワイプ操作。
- 自動監査の成功はVoiceOverの実利用確認と同一ではない。未確認のアクセシビリティ対応をストアへ申告しない。

## 提出時の操作分担と未確認項目

利用者は9月8日にArchive、アップロード、ストア入力を依頼。最後の審査提出は利用者が行った。
審査承認後はシリーズ標準の自動リリースで公開済み。日時と根拠は冒頭を参照する。
9月9日、利用者の明示指示で実機VoiceOver音声確認を今回はスキップ。未確認として残す。
App Store配布版からの更新、過去記録ありの実機更新、TestFlightでの実機確認も未実施。

## Archive・検証・ストア準備結果（9月8〜9日時点の履歴）

- 9月8日、上記コミットから署名付きRelease Archive成功。
  `/Users/satoutakuya/Library/Developer/Xcode/Archives/2026-09-08/SeikatsuBoardCount-1.0.1-Build2.xcarchive`
- ArchiveのVersion 1.0.1、Build 2、Bundle ID、Team、arm64を照合し、コード署名検証に成功。
- 同じコミットのiPhone 17 / iOS 26.5 Simulatorテストは26件成功、失敗・スキップ0件。
  `/private/tmp/count-release-101-validation.xcresult`。単体23件と復旧UI3件を含む。
  既知のAppIntents未使用のメタデータ抽出警告のみ。実機VoiceOver確認とは区別する。
- 9月8日21:50 JST、Xcode Organizerで `1.0.1 (2) uploaded` と `Uploaded to Apple` を確認。
  Xcodeの通常App Store Connect配布を使用。最終審査提出は実行していない。
- 9月9日、ChromeのApp Store ConnectでBuild 2の処理完了・選択保存を確認。
  Build ID: `8e70d6cc-e7d3-44aa-8779-c977e685d3c1`。
- 次回名称「生活ボードカウント」、名称を合わせた概要、従来のプロモーション文、上記最新情報と審査メモを保存。
  マーケティングURLへ `https://satou-studio.github.io/seikatsu-board-site/#count` を設定。
  既存スクリーンショット3枚・サポートURL・キーワード・審査連絡先は維持。
- 承認後の自動リリース、段階的リリースなし、既存評価を維持、ログイン不要。
  未検証のVoiceOver対応申告は追加していない。
- 9月9日05:56 JST、名前変更を含め「審査用に追加」完了。状態は「審査準備完了」。
  提出物の下書きに `1.0.1 (2)` と有効な **「審査へ提出」** ボタンが表示されたところで停止。
  [最終操作の画面](https://appstoreconnect.apple.com/apps/6794626819/distribution/ios/version/inflight)
- ここまでの記録はアップロード・提出準備の証拠。後日の審査承認・公開の根拠は冒頭へ追記した。
  9月21日の更新開始時点で、既存コミット`7988248`までGitHubの`main`との同期を確認した。
  Archive元`2cf7ac3`以降の変更は資料のみで、アプリのソース・設定は変えていない。

## 実機検証中の初期化と復元

- 9月8日の手動確認で、揮発性起動引数の異常値を使った復旧案内から初期化が確定された。
  実際の保存先は項目0件・記録0件となり、控えには試験用文字列が保存された。
  この方法は確定操作まで行うと実データを上書きするため、実データ入り端末の手動検証には使用しない。
- その時点の空状態と控えをMacの一時領域へ保全し、事情と復元限界を利用者へ説明。
  利用者は前回更新時の控え（項目5件・記録0件）への復元を明示承認した。
- 9月9日05:57 JST、対象アプリの保存ファイルだけを前回の控えから復元し、テスト引数なしで通常起動。
  読み戻した保存値が前回控えの元バイト列と完全一致し、項目5件・記録0件であることを確認。
  それ以降に追加した記録が戻ったという意味ではない。画面表示の利用者確認は別途扱う。
- 元記録、個人の項目内容、端末の控えはGitやAppleへのアップロードに含めていない。
