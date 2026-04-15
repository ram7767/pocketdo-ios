//
// MARK: - File: pocketdoApp.swift (AppEntry)
// This is the @main entry for PocketDo.
// If you see a conflict with the old pocketdo_iosApp.swift, delete that file:
//   In Xcode → right-click old file → Delete → Move to Trash

import SwiftUI

@main
struct pocketdoApp: App {
    @StateObject private var container = DependencyContainer()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(container)
                .environmentObject(container.authService)
                .environmentObject(container.syncService)
                .environmentObject(container.subscriptionService)
                .preferredColorScheme(themeManager.colorScheme)
                .task {
                    // UI Testing: auto-authenticate as guest so tests skip auth screen
                    if CommandLine.arguments.contains("--uitesting") {
                        try? await container.authService.continueAsGuest()
                    }
                }
        }
    }
}
