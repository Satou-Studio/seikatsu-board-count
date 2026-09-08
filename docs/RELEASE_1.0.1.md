# 生活ボードカウント 1.0.1 / Build 2

更新日: 2026-09-08

## 採番と対象

- シリーズ `docs/RELEASE_GUIDE.md` に従い、記録保護の不具合修正をパッチ更新 `1.0.1` とする。
- 9月8日にログイン済みApp Store ConnectのTestFlightで既存は `1.0 / Build 1` のみと確認。次のアップロードを Build 2 とする。
- 保存形式の `schemaVersion: 1` はアプリの公開バージョンとは独立した番号。旧形式の読込互換性を維持する。
- Bundle ID: `com.saku.seikatsuboardcount`、Apple ID: `6794626819`、Team: `4W95W79JT2`。
- Project / Target / Scheme: `SeikatsuBoardCount`。iPhone専用、iOS 17以上を維持。
- ホーム画面・次回App Store名: `生活ボードカウント`。
- 修正ソース: `e79a25f`。採番コミットとArchiveの対応は作成後に記録する。

## このバージョンの最新情報

記録をより安心して使い続けられるよう、保存データの読み込みを改善しました。

・記録を読み込めない場合に、見本のデータで自動的に上書きしないようにしました。
・すべての項目を削除したあと、再起動しても見本が再び追加されないようにしました。
・読み込みに問題がある場合の案内と、元データの控えを残して空の状態から始める操作を追加しました。
・アプリの表示名を「生活ボードカウント」に統一しました。

## 審査メモ案

This update improves local saved-data protection. No account, login, ads, in-app purchases, or server connection is required. Existing item IDs, daily records, and storage keys are preserved.

If saved data cannot be read, the app keeps the original data unchanged and temporarily disables editing. The user can retry loading, or explicitly confirm starting with an empty state after a local copy of the original value is saved and verified. If that copy cannot be saved, no reset occurs. There is no automatic restoration/import feature for the copy. This error screen is not shown during normal use.

The app remains iPhone-only. The Japanese display name is now 生活ボードカウント. Normal counting and history features are unchanged.

## 検証の区別

- 完了: 単体23件・復旧UI3件、ライト／ダーク自動アクセシビリティ監査、最大文字の操作（9月7日）。
- 完了: 開発用旧版から実機への上書き、項目5件・記録0件の保存値一致（9月8日）。
- 完了: 実機で記録追加、終了・再起動後の保持、取消。利用者が9月8日に確認済み。
- 未確認: App Store配布版からの更新、過去記録ありの実機更新、実際のVoiceOver音声・スワイプ操作。
- 自動監査の成功はVoiceOverの実利用確認と同一ではない。未確認のアクセシビリティ対応をストアへ申告しない。

## 提出境界

利用者は9月8日にArchive、アップロード、ストア入力を依頼。最後の審査提出は利用者が行う。
審査提出・公開は未実施。審査承認後はシリーズ標準の自動リリースを使用する。
公開前の実機確認は省略した扱いにせず、残項目を利用者へ明示する。
