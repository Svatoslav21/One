import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    var screenshotDir: String {
        let subdir: String
        if let content = try? String(contentsOfFile: "/tmp/screenshot_subdir.txt", encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            subdir = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            subdir = "Screenshots"
        }
        return "/Users/sadygsadygov/Desktop/new_dom/One/\(subdir)"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotDir)/\(name).png")
        try? data.write(to: url)
    }

    @MainActor
    func testCaptureAllScreenshots() throws {
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        sleep(3)
        saveScreenshot("01-onboarding-welcome")

        app.buttons["Get Started"].tap()
        sleep(2)
        saveScreenshot("02-onboarding-name")

        app.buttons["Continue"].tap()
        sleep(2)
        saveScreenshot("03-onboarding-goal")

        app.buttons["Continue"].tap()
        sleep(2)
        saveScreenshot("04-onboarding-ready")

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(3)
        saveScreenshot("05-dashboard-energy-ring")

        let window = app.windows.firstMatch
        window.swipeUp()
        sleep(1)
        saveScreenshot("06-dashboard-insights")

        window.swipeUp()
        sleep(1)
        saveScreenshot("07-dashboard-heatmap")

        window.swipeDown()
        window.swipeDown()
        sleep(1)
        let logBtn = app.buttons["Log Today's Energy"]
        if logBtn.waitForExistence(timeout: 3) {
            logBtn.tap()
            sleep(2)
            saveScreenshot("08-log-entry-sheet")

            let cancelBtn = app.buttons["Cancel"]
            if cancelBtn.waitForExistence(timeout: 2) {
                cancelBtn.tap()
            } else {
                app.swipeDown()
                app.swipeDown()
            }
            sleep(2)
        }

        let settingsBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'gearshape' OR label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'gear'")).firstMatch
        if settingsBtn.waitForExistence(timeout: 3) {
            settingsBtn.tap()
            sleep(2)
            saveScreenshot("09-settings")

            window.swipeUp()
            sleep(1)
            saveScreenshot("10-settings-detail")
        }
    }
}
