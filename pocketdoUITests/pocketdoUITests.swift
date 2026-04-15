// MARK: - File: pocketdoUITests/pocketdoUITests.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//
//  UI Tests — Sequential screen-by-screen flow.
//  Each test class is independent. Two launch modes:
//    • No args          → starts at Auth screen (used by AuthTests only)
//    • ["--uitesting"]  → app auto-authenticates as Guest, lands on Dashboard
//
//  Screenshots are saved as XCTAttachment(lifetime: .keepAlways).
//  View them in Xcode: Test Report → select test → Attachments tab.

import XCTest

// ═══════════════════════════════════════════════════════════
// MARK: - Base Test Case
// ═══════════════════════════════════════════════════════════

class PocketDoBaseUITest: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Launch Helpers

    /// Launches the app in UI-test mode (skips auth, lands on Dashboard).
    func launchApp() {
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        // Give the auto-guest-login a moment to complete
        wait(seconds: 1.2)
        // Confirm we landed on the main tab bar
        XCTAssertTrue(
            app.buttons["tab_dashboard"].waitForExistence(timeout: 8),
            "App should show the main tab bar after --uitesting launch"
        )
    }

    /// Launches the app with NO arguments — stays on Auth screen.
    func launchAppAtAuthScreen() {
        app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        wait(seconds: 0.6)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation

    func tapTab(_ id: String, waitAfter: TimeInterval = 0.5) {
        let btn = app.buttons[id]
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Tab '\(id)' should exist")
        btn.tap()
        wait(seconds: waitAfter)
    }

    func tapFAB(waitAfter: TimeInterval = 0.7) {
        let fab = app.buttons["fab_addTask"]
        XCTAssertTrue(fab.waitForExistence(timeout: 5), "FAB should exist")
        fab.tap()
        wait(seconds: waitAfter)
    }

    func dismissSheet() {
        app.swipeDown(velocity: .fast)
        wait(seconds: 0.5)
    }

    // MARK: - Screenshot

    @MainActor
    func screenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Wait

    func wait(seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    func waitFor(_ element: XCUIElement, timeout: TimeInterval = 6) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 01 · Auth Screen
// ═══════════════════════════════════════════════════════════

final class Test01_AuthScreen: PocketDoBaseUITest {

    /// Step-by-step Auth flow: open screen → fill email → tap Guest login
    @MainActor
    func test_authScreen_fullFlow() throws {
        // ── Launch at Auth (no --uitesting) ───────────────
        launchAppAtAuthScreen()

        // STEP 1: Auth screen is displayed
        let loginBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Log In'")
        ).firstMatch
        XCTAssertTrue(loginBtn.waitForExistence(timeout: 8), "Login button must be visible")
        screenshot("01-auth-01_login_screen")

        // STEP 2: Tap first text field (email) and type
        let emailField = app.textFields.firstMatch
        if emailField.waitForExistence(timeout: 4) {
            emailField.tap()
            wait(seconds: 0.3)
            emailField.typeText("demo@pocketdo.app")
            screenshot("01-auth-02_email_filled")
        }

        // STEP 3: Tap the password field and type
        let secureFields = app.secureTextFields
        if secureFields.firstMatch.waitForExistence(timeout: 3) {
            secureFields.firstMatch.tap()
            wait(seconds: 0.3)
            secureFields.firstMatch.typeText("password123")
            screenshot("01-auth-03_password_filled")
        }

        // STEP 4: Tap "Continue as Guest" to bypass login
        let guestBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Guest'")
        ).firstMatch
        XCTAssertTrue(guestBtn.waitForExistence(timeout: 5), "Guest button must exist")
        guestBtn.tap()
        wait(seconds: 1.0)

        // STEP 5: Confirm main app appeared
        XCTAssertTrue(
            app.buttons["tab_dashboard"].waitForExistence(timeout: 8),
            "Dashboard tab should appear after guest login"
        )
        screenshot("01-auth-04_after_guest_login")
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 02 · Dashboard Screen
// ═══════════════════════════════════════════════════════════

final class Test02_DashboardScreen: PocketDoBaseUITest {

    @MainActor
    func test_dashboardScreen_fullFlow() throws {
        // ── Launch directly on Dashboard ──────────────────
        launchApp()
        tapTab("tab_dashboard")

        // STEP 1: Dashboard top — stats visible
        screenshot("02-dashboard-01_top")

        // STEP 2: Scroll down to see full content
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 3) {
            scrollView.swipeUp(velocity: .slow)
            wait(seconds: 0.5)
            screenshot("02-dashboard-02_scrolled_down")

            // STEP 3: Scroll back up
            scrollView.swipeDown(velocity: .slow)
            wait(seconds: 0.4)
            screenshot("02-dashboard-03_scrolled_back_up")
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 03 · Add Task Sheet
// ═══════════════════════════════════════════════════════════

final class Test03_AddTaskSheet: PocketDoBaseUITest {

    @MainActor
    func test_addTaskSheet_fullFlow() throws {
        launchApp()
        tapTab("tab_dashboard")

        // STEP 1: Tap FAB to open Add Task sheet
        tapFAB()
        screenshot("03-addtask-01_sheet_open")

        // STEP 2: Type a task title
        let titleField = app.textFields.firstMatch
        if titleField.waitForExistence(timeout: 4) {
            titleField.tap()
            wait(seconds: 0.3)
            titleField.typeText("Design the onboarding flow")
            wait(seconds: 0.3)
            screenshot("03-addtask-02_title_filled")
        }

        // STEP 3: Tap "High" priority segment
        let highPriority = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'High'")
        ).firstMatch
        if highPriority.waitForExistence(timeout: 3) {
            highPriority.tap()
            wait(seconds: 0.3)
            screenshot("03-addtask-03_high_priority_selected")
        }

        // STEP 4: Enable deadline toggle (look for Toggle / Switch)
        let deadlineToggle = app.switches.firstMatch
        if deadlineToggle.waitForExistence(timeout: 3) {
            deadlineToggle.tap()
            wait(seconds: 0.4)
            screenshot("03-addtask-04_deadline_enabled")
        }

        // STEP 5: Save button
        let saveBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Save' OR label CONTAINS 'Add'")
        ).firstMatch
        if saveBtn.waitForExistence(timeout: 3) {
            screenshot("03-addtask-05_ready_to_save")
            saveBtn.tap()
            wait(seconds: 0.7)
            screenshot("03-addtask-06_after_save")
        } else {
            dismissSheet()
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 04 · Search Screen
// ═══════════════════════════════════════════════════════════

final class Test04_SearchScreen: PocketDoBaseUITest {

    @MainActor
    func test_searchScreen_fullFlow() throws {
        launchApp()
        tapTab("tab_search", waitAfter: 0.8)

        // STEP 1: Idle state — "What are you looking for?" prompt
        screenshot("04-search-01_idle_state")

        // STEP 2: Tap search field and type a query
        let searchField = app.textFields["searchTextField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search text field must exist")
        searchField.tap()
        wait(seconds: 0.3)
        searchField.typeText("design")

        // Wait for 300ms debounce + results animation
        wait(seconds: 0.8)
        screenshot("04-search-02_query_typed")

        // STEP 3: Results or no-results state
        let resultsExist = app.scrollViews.firstMatch.exists
        screenshot(resultsExist
            ? "04-search-03_results_visible"
            : "04-search-03_no_results")

        // STEP 4: Clear the query using the X button
        let clearX = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'xmark' OR label CONTAINS 'Clear'")
        ).firstMatch
        if clearX.waitForExistence(timeout: 2) {
            clearX.tap()
            wait(seconds: 0.5)
            screenshot("04-search-04_search_cleared")
        }

        // STEP 5: Type a term that returns no results
        searchField.tap()
        wait(seconds: 0.2)
        searchField.typeText("xyzzy_no_match_99999")
        wait(seconds: 0.8)
        screenshot("04-search-05_empty_state")

        // STEP 6: Tap "Clear filters" / "Clear" CTA
        let clearFilters = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Clear' OR label CONTAINS 'filter'")
        ).firstMatch
        if clearFilters.waitForExistence(timeout: 2) {
            clearFilters.tap()
            wait(seconds: 0.4)
            screenshot("04-search-06_after_clear_filters")
        }

        // STEP 7: Tag chip interaction (if tags exist)
        let firstChip = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'filter'")
        ).firstMatch
        if firstChip.waitForExistence(timeout: 2) {
            firstChip.tap()
            wait(seconds: 0.7)
            screenshot("04-search-07_tag_chip_active")

            // Deactivate the chip
            firstChip.tap()
            wait(seconds: 0.4)
            screenshot("04-search-08_tag_chip_deactivated")
        } else {
            screenshot("04-search-07_no_tag_chips_yet")
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 05 · Settings Screen
// ═══════════════════════════════════════════════════════════

final class Test05_SettingsScreen: PocketDoBaseUITest {

    @MainActor
    func test_settingsScreen_fullFlow() throws {
        launchApp()
        tapTab("tab_settings", waitAfter: 0.8)

        // STEP 1: Settings top section
        screenshot("05-settings-01_top")

        // STEP 2: Scroll down through settings
        let scrollView = app.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 3) {
            scrollView.swipeUp(velocity: .slow)
            wait(seconds: 0.5)
            screenshot("05-settings-02_scrolled")
        }

        // STEP 3: Look for Theme / Appearance toggle
        let themeToggle = app.switches.firstMatch
        if themeToggle.waitForExistence(timeout: 2) {
            screenshot("05-settings-03_theme_toggle_visible")
            themeToggle.tap()
            wait(seconds: 0.5)
            screenshot("05-settings-04_theme_toggled")
            // Restore
            themeToggle.tap()
            wait(seconds: 0.3)
        }

        // STEP 4: Look for Go Premium / Upgrade button
        let premiumBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[cd] 'premium' OR label CONTAINS[cd] 'upgrade' OR label CONTAINS[cd] 'Pro'")
        ).firstMatch
        if premiumBtn.waitForExistence(timeout: 2) {
            screenshot("05-settings-05_premium_cta_visible")
            premiumBtn.tap()
            wait(seconds: 0.8)
            screenshot("05-settings-06_premium_screen_opened")
            // Dismiss premium modal/sheet
            dismissSheet()
            wait(seconds: 0.5)
        }

        // STEP 5: Scroll back to top for final shot
        let topScrollView = app.scrollViews.firstMatch
        if topScrollView.waitForExistence(timeout: 2) {
            topScrollView.swipeDown(velocity: .slow)
            wait(seconds: 0.4)
        }
        screenshot("05-settings-07_final")
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 06 · Full App Sequential Flow (Combined)
// ═══════════════════════════════════════════════════════════
// This single test walks through EVERY screen in one run —
// ideal for generating a complete screenshot set in CI.

final class Test06_FullAppFlow: PocketDoBaseUITest {

    @MainActor
    func test_fullAppScreenshotFlow() throws {

        // ─── PHASE A: Auth Screen ─────────────────────────
        launchAppAtAuthScreen()

        let loginVisible = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Log In'")
        ).firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(loginVisible, "Should see Auth screen on fresh launch")
        screenshot("FULL-01_auth_screen")

        // Tap "Continue as Guest"
        let guestBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Guest'")
        ).firstMatch
        XCTAssertTrue(guestBtn.waitForExistence(timeout: 5))
        guestBtn.tap()
        XCTAssertTrue(app.buttons["tab_dashboard"].waitForExistence(timeout: 8))
        screenshot("FULL-02_landed_on_dashboard")

        // ─── PHASE B: Dashboard ───────────────────────────
        tapTab("tab_dashboard", waitAfter: 0.6)
        screenshot("FULL-03_dashboard_top")

        if app.scrollViews.firstMatch.waitForExistence(timeout: 3) {
            app.scrollViews.firstMatch.swipeUp(velocity: .slow)
            wait(seconds: 0.5)
            screenshot("FULL-04_dashboard_scrolled")
            app.scrollViews.firstMatch.swipeDown(velocity: .slow)
            wait(seconds: 0.3)
        }

        // ─── PHASE C: Add Task Sheet ──────────────────────
        tapFAB()
        screenshot("FULL-05_add_task_sheet")

        let titleField = app.textFields.firstMatch
        if titleField.waitForExistence(timeout: 4) {
            titleField.tap()
            wait(seconds: 0.3)
            titleField.typeText("Ship PocketDo v1.0")
            wait(seconds: 0.2)
            screenshot("FULL-06_add_task_filled")
        }

        let highBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'High'")
        ).firstMatch
        if highBtn.waitForExistence(timeout: 2) {
            highBtn.tap()
            wait(seconds: 0.2)
            screenshot("FULL-07_add_task_high_priority")
        }

        // Save or dismiss
        let saveBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Save' OR label CONTAINS 'Add'")
        ).firstMatch
        if saveBtn.waitForExistence(timeout: 2) {
            saveBtn.tap()
            wait(seconds: 0.6)
            screenshot("FULL-08_after_task_saved")
        } else {
            dismissSheet()
        }

        // ─── PHASE D: Search Screen ───────────────────────
        tapTab("tab_search", waitAfter: 0.8)
        screenshot("FULL-09_search_idle")

        let searchField = app.textFields["searchTextField"]
        if searchField.waitForExistence(timeout: 4) {
            searchField.tap()
            wait(seconds: 0.3)
            searchField.typeText("ship")
            wait(seconds: 0.8) // debounce
            screenshot("FULL-10_search_results")
        }

        // Tag filter chips
        let firstChip = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'filter'")
        ).firstMatch
        if firstChip.waitForExistence(timeout: 2) {
            firstChip.tap()
            wait(seconds: 0.6)
            screenshot("FULL-11_search_tag_filter_active")
            firstChip.tap()
            wait(seconds: 0.4)
        }

        // Clear search
        let clearBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Clear'")
        ).firstMatch
        if clearBtn.waitForExistence(timeout: 2) {
            clearBtn.tap()
            wait(seconds: 0.4)
            screenshot("FULL-12_search_cleared")
        }

        // ─── PHASE E: Settings Screen ──────────────────────
        tapTab("tab_settings", waitAfter: 0.8)
        screenshot("FULL-13_settings_top")

        if app.scrollViews.firstMatch.waitForExistence(timeout: 3) {
            app.scrollViews.firstMatch.swipeUp(velocity: .slow)
            wait(seconds: 0.5)
            screenshot("FULL-14_settings_scrolled")
        }

        // ─── PHASE F: Premium Screen ──────────────────────
        let premiumBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[cd] 'premium' OR label CONTAINS[cd] 'upgrade' OR label CONTAINS[cd] 'Pro'")
        ).firstMatch
        if premiumBtn.waitForExistence(timeout: 3) {
            premiumBtn.tap()
            wait(seconds: 0.8)
            screenshot("FULL-15_premium_screen")
            dismissSheet()
            wait(seconds: 0.5)
        }

        screenshot("FULL-16_final")
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - 07 · Launch Performance
// ═══════════════════════════════════════════════════════════

final class Test07_LaunchPerformance: XCTestCase {

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["--uitesting"]
            app.launch()
        }
    }
}
