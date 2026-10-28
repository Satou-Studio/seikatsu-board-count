import XCTest

final class RecoveryUITests: XCTestCase {
    @MainActor
    func testParentSupportFromTodayDoesNotReplaceChildControls() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["できたをふやす"].exists)
        XCTAssertTrue(app.buttons["きろくするひをえらぶ"].exists)
        screenshot(app, name: "parent-support-today-top")
        for _ in 0..<12 {
            if app.buttons["support.entry"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["support.entry"].isHittable)
        screenshot(app, name: "parent-support-today-entry")
        app.buttons["support.entry"].tap()
        XCTAssertTrue(app.buttons["support.close"].waitForExistence(timeout: 3))
        app.buttons["support.close"].tap()
        XCTAssertTrue(app.tabBars.firstMatch.exists)
        XCTAssertTrue(app.buttons["support.entry"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testParentSupportFromRecoveryAndMailFallback() throws {
        try verifyParentSupportAndMailFallback(style: "Light")
    }

    @MainActor
    func testParentSupportDarkAuditAndMailFallback() throws {
        try verifyParentSupportAndMailFallback(style: "Dark")
    }

    @MainActor
    private func verifyParentSupportAndMailFallback(style: String) throws {
        let app = launchRecovery(style: style)
        app.swipeUp()
        let entry = app.buttons["support.entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 3))
        entry.tap()
        XCTAssertTrue(app.buttons["support.help"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["support.review"].exists)
        XCTAssertTrue(app.staticTexts["support.address"].exists)
        for (id, label) in [("support.help", "使い方・お問い合わせ"), ("support.mail", "ご意見をメールで送る"), ("support.review", "App Storeでレビューを書く")] {
            XCTAssertTrue(app.buttons[id].label.contains(label))
            XCTAssertGreaterThanOrEqual(app.buttons[id].frame.height, 44)
        }
        XCTAssertLessThan(app.buttons["support.help"].frame.minY, app.buttons["support.mail"].frame.minY)
        XCTAssertLessThan(app.buttons["support.mail"].frame.minY, app.buttons["support.review"].frame.minY)
        XCTAssertEqual(app.staticTexts["support.address"].label, "お問い合わせのメールアドレス")
        screenshot(app, name: "parent-support-light")
        app.buttons["support.mail"].tap()
        // Dedicated Simulator has no configured mail account; no real send is attempted.
        XCTAssertTrue(app.buttons["support.mailFallbackClose"].waitForExistence(timeout: 10))
        screenshot(app, name: "parent-support-mail-unavailable")
        try app.performAccessibilityAudit()
        app.buttons["support.mailFallbackClose"].tap()
        // The parent remains in the accessibility tree during sheet dismissal.
        // Wait for the outgoing sheet to disappear before auditing the parent.
        XCTAssertTrue(app.buttons["support.mailFallbackClose"].waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.buttons["support.help"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["support.help"].isHittable)
        try app.performAccessibilityAudit()
        app.buttons["support.close"].tap()
        XCTAssertTrue(app.buttons["recovery.retry"].waitForExistence(timeout: 3))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["記録を読み込めませんでした"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testParentSupportLargestText() throws {
        try verifyParentSupportLargestText(style: "Dark")
    }

    @MainActor
    func testParentSupportLargestTextLight() throws {
        try verifyParentSupportLargestText(style: "Light")
    }

    @MainActor
    private func verifyParentSupportLargestText(style: String) throws {
        let app = launchRecovery(style: style, largeText: true)
        for _ in 0..<10 {
            if app.buttons["support.entry"].isHittable { break }
            app.swipeUp()
        }
        app.buttons["support.entry"].tap()
        XCTAssertTrue(app.buttons["support.close"].waitForExistence(timeout: 3))
        screenshot(app, name: "parent-support-largest-text-top")
        for id in ["support.help", "support.mail", "support.review"] {
            for _ in 0..<10 {
                if app.buttons[id].isHittable { break }
                app.swipeUp()
            }
            XCTAssertTrue(app.buttons[id].isHittable)
            XCTAssertGreaterThanOrEqual(app.buttons[id].frame.height, 44)
        }
        app.swipeUp()
        screenshot(app, name: "parent-support-largest-text-bottom")
        let mail = app.buttons["support.mail"]
        for _ in 0..<16 {
            let top = app.buttons["support.close"].frame.maxY + 20
            let bottom = app.frame.maxY - 20
            if mail.isHittable && mail.frame.midY > top && mail.frame.midY < bottom { break }
            if mail.frame.midY <= top {
                app.swipeDown(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }
        // isHittable alone may include a partially visible label behind the
        // pinned header. Exercise the button with its center in the content area.
        XCTAssertGreaterThan(mail.frame.midY, app.buttons["support.close"].frame.maxY + 20)
        XCTAssertLessThan(mail.frame.midY, app.frame.maxY - 20)
        screenshot(app, name: "parent-support-mail-largest-before-tap")
        mail.tap()
        XCTAssertTrue(app.buttons["support.mailFallbackClose"].waitForExistence(timeout: 10))
        screenshot(app, name: "parent-support-mail-largest-top")
        for _ in 0..<12 { app.swipeUp() }
        screenshot(app, name: "parent-support-mail-largest-bottom")
        XCTAssertTrue(app.buttons["support.mailFallbackClose"].isHittable)
        app.buttons["support.mailFallbackClose"].tap()
        XCTAssertTrue(app.buttons["support.mailFallbackClose"].waitForNonExistence(timeout: 5))
        app.buttons["support.close"].tap()
        XCTAssertTrue(app.buttons["support.entry"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testSupportLinkAndReturnWithoutSending() async throws {
        // Remove the unsupported App Store URL left in Simulator Safari by a
        // previous run. Only run this suite on the dedicated test Simulator.
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.terminate()
        let app = launchRecovery(style: "Light")
        app.swipeUp()
        app.buttons["support.entry"].tap()
        XCTAssertTrue(app.buttons["support.help"].waitForExistence(timeout: 3))
        app.buttons["support.help"].tap()
        guard safari.wait(for: .runningForeground, timeout: 15) else {
            XCTFail("Simulator did not foreground Safari after the support action")
            return
        }
        let supportHeading = safari.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "生活ボードカウント")).firstMatch
        XCTAssertTrue(supportHeading.waitForExistence(timeout: 30))
        XCTAssertTrue(supportHeading.isHittable)
        // The web accessibility tree can arrive before the rendered page surface.
        try await Task.sleep(for: .seconds(1))
        screenshot(safari, name: "parent-support-browser-destination")
        app.activate()
        XCTAssertTrue(app.buttons["support.review"].waitForExistence(timeout: 5))
        app.buttons["support.review"].tap()
        let reviewAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        reviewAttachment.name = "parent-support-review-simulator-result"
        reviewAttachment.lifetime = .keepAlways
        add(reviewAttachment)
        app.activate()
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["閉じる"].tap()
        }
        XCTAssertTrue(app.buttons["support.close"].exists)
        app.buttons["support.close"].tap()
        XCTAssertTrue(app.buttons["recovery.retry"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchRecovery(style: String, largeText: Bool = false) -> XCUIApplication {
        let previousAppearance = XCUIDevice.shared.appearance
        XCUIDevice.shared.appearance = style == "Dark" ? .dark : .light
        addTeardownBlock { @MainActor in
            XCUIDevice.shared.appearance = previousAppearance
        }
        let app = XCUIApplication()
        // Volatile launch-argument domain: never damage the Simulator's saved records.
        app.launchArguments = [
            "-seikatsuboard-count-state-v1", "unreadable-ui-test-value",
            "-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"
        ]
        if largeText {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        app.launch()
        XCTAssertTrue(app.staticTexts["記録を読み込めませんでした"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    func testRecoveryLightRetryCancelAndRestart() throws {
        let app = launchRecovery(style: "Light")
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        app.buttons["recovery.retry"].tap()
        XCTAssertTrue(app.staticTexts["記録を読み込めませんでした"].exists)
        screenshot(app, name: "recovery-light")
        try app.performAccessibilityAudit()
        app.buttons["recovery.startOver"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.alerts.staticTexts["これまでの項目と記録を使わずに始めますか？"].exists)
        screenshot(app, name: "recovery-confirmation")
        app.alerts.buttons["キャンセル"].tap()
        XCTAssertTrue(app.buttons["recovery.retry"].exists)
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["記録を読み込めませんでした"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testRecoveryDarkAccessibility() throws {
        let app = launchRecovery(style: "Dark")
        screenshot(app, name: "recovery-dark")
        try app.performAccessibilityAudit()
        for _ in 0..<8 {
            if app.buttons["recovery.startOver"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["recovery.retry"].isHittable)
        XCTAssertTrue(app.buttons["recovery.startOver"].isHittable)
    }

    @MainActor
    func testRecoveryLargestTextCanReachActions() throws {
        let app = launchRecovery(style: "Dark", largeText: true)
        screenshot(app, name: "recovery-largest-text-top")
        for _ in 0..<8 {
            if app.buttons["recovery.startOver"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["recovery.startOver"].isHittable)
        app.swipeUp()
        screenshot(app, name: "recovery-largest-text-actions")
        app.buttons["recovery.startOver"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
        app.alerts.buttons["キャンセル"].tap()
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    @MainActor
    private func screenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
