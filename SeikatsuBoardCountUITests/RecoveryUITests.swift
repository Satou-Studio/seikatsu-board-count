import XCTest

final class RecoveryUITests: XCTestCase {
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
