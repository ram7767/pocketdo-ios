// MARK: - File: pocketdoUITests/pocketdoUITestsLaunchTests.swift
//  pocketdo
//
//  Retained for Xcode's per-configuration launch test scaffold.
//  Full screenshot suite is in pocketdoUITests.swift (Test06_FullAppFlow).

import XCTest

final class pocketdoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        // Use --uitesting so the app skips auth and lands on Dashboard
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Wait for the tab bar to confirm the app is ready
        _ = app.buttons["tab_dashboard"].waitForExistence(timeout: 8)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "00_launch_screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
