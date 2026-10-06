// Copy into the UI TEST file of an exported temporary checkout only.
import XCTest

final class StorefrontCaptureTests: XCTestCase {
    @MainActor
    func testCaptureJapaneseStorefront() throws {
        guard ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == "Count-Storefront-20261006" else {
            throw XCTSkip("Dedicated screenshot Simulator required")
        }
        continueAfterFailure = false
        XCUIDevice.shared.appearance = .light
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.staticTexts["はみがき"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["きょう 2かい"].exists)
        XCTAssertTrue(app.staticTexts["きょう 1かい"].exists)
        capture(app, "01-today")

        app.tabBars.buttons["きろく"].tap()
        XCTAssertTrue(app.staticTexts["ぜんぶで 3かい"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["ぜんぶで 2かい"].exists)
        capture(app, "02-history")
        app.swipeUp()
        app.swipeUp()
        capture(app, "history-older-days")

        app.tabBars.buttons["きょう"].tap()
        app.buttons["できたをふやす"].tap()
        XCTAssertTrue(app.textFields["はみがき"].waitForExistence(timeout: 5))
        app.textFields["はみがき"].tap()
        app.textFields["はみがき"].typeText("おかたづけ\n")
        app.textFields["🪥"].tap()
        app.textFields["🪥"].typeText("🧸\n")
        if app.keyboards.firstMatch.exists {
            print("Keyboard buttons: \(app.keyboards.buttons.allElementsBoundByIndex.map(\.label))")
            let returnKey = app.keyboards.buttons.matching(NSPredicate(format: "label IN %@", ["Return", "return", "改行", "完了", "Done", "done"])).firstMatch
            if returnKey.exists { returnKey.tap() }
        }
        capture(app, "editor-keyboard-diagnostic")
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.buttons["ほぞん"].isEnabled)
        XCTAssertTrue(app.buttons["ほぞん"].isHittable)
        capture(app, "03-add-item")
        app.buttons["ほぞん"].tap()
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["おかたづけ"].waitForExistence(timeout: 5))
        capture(app, "added-item-verification")

        app.terminate()
        XCUIDevice.shared.appearance = .dark
        app.launch()
        XCTAssertTrue(app.staticTexts["はみがき"].waitForExistence(timeout: 10))
        capture(app, "today-dark-verification")
        app.tabBars.buttons["きろく"].tap()
        capture(app, "history-dark-verification")
        XCUIDevice.shared.appearance = .light
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
