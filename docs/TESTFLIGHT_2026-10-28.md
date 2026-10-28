# 本人向けTestFlight配信（2026-10-28）

対象: 生活ボードカウント / App ID 6794626819。
ユーザーの実機確認用配信依頼に基づく内部テスト。審査提出・一般公開は対象外。

## 配信元

- ソース: `26156ddf19cc4c7999d15262d6be5805604cf004`（GitHub反映済み）。
- Version 1.1 / Build 4。Archive時に設定値を指定。
- 作業フォルダに既存の未コミット画面調整があるため、原状を保全し、`git archive HEAD`で取り出した確定済みコードから作成。未コミット差分はバイナリに含まない。
- 保存形式・保存キー・記録ID・既存記録の変更なし。
- Release Archive成功。Xcodeの既存アカウントと自動署名を利用。
- Archive: `/private/tmp/Count-1.1-Build4-20261028.xcarchive`。
- アップロードログ: `/private/tmp/count-flight-upload-20261028.log`。

## Apple側

- 更新Apple Developer Program License Agreement（発効2026-10-14）は、ユーザーの明示承認後に同意。Apple側同意日2026-10-28を確認。
- 内部グループ「本人確認用」を作成。自動配信OFF、本人1名のみ追加。外部グループ・公開リンクなし。
- グループID: `81c6356d-ae0e-4246-8299-d57f0e6110cb`。
- アップロード成功（`EXPORT SUCCEEDED`）、Apple処理完了。1.1（4）を本人用グループへ割当し、Connectで「テスト中」・1名／1ビルド・残90日を確認。
- Build ID: `e8f2a3ff-246c-4132-baf6-3eabfa81395d`。
- [配信状態の画面](count-testflight-1.1-build4-20261028.png)。招待メールの実際の受信・本人のインストールは未確認。

## 検証

今回の配信元コードで単体テスト24件成功、失敗・スキップ0。専用iPhone 17 Pro Max Simulator（iOS 26.5）で実行。結果は `/private/tmp/count-flight-unit-20261028/Logs/Test/Test-SeikatsuBoardCount-2026.10.28_12-12-55-+0900.xcresult`。UI／アクセシビリティの既知の限界は `PARENT_FEEDBACK.md` の記録を引き継ぐ。作業フォルダの未コミット画面調整についての検証結果ではない。

## 実機確認（配信後、利用者が実施）

アプリを削除・初期化せずTestFlightから更新し、既存項目・記録の保持、保護者向け入口と閉じる操作、サポート表示後の復帰、メール下書きの宛先・件名・案内と中止後の復帰、レビュー投稿先、最大文字・VoiceOverを確認する。メール送信・レビュー投稿は不要。

実機検証・公開版反映・利用効果は未確認。公開版の更新や審査提出を、この内部配信と同一扱いにしない。
