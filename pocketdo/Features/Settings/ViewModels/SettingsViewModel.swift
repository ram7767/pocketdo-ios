// MARK: - File: Features/Settings/ViewModels/SettingsViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published State
    @Published var colorMode: AppColorMode = .system
    @Published var notificationsEnabled: Bool = true
    @Published var selectedLanguage: String = "English"
    @Published var isLoading: Bool = false
    @Published var toastMessage: String? = nil
    @Published var showDeleteConfirm: Bool = false
    @Published var showChangePassword: Bool = false

    // Edit profile
    @Published var editName: String = ""
    @Published var editEmail: String = ""
    @Published var isEditingProfile: Bool = false

    // MARK: - Dependencies
    let authService: AuthService
    let syncService: SyncService
    private let logoutUseCase: LogoutUseCase

    let availableLanguages = ["English", "Spanish", "French", "German", "Hindi", "Tamil"]

    // MARK: - Init
    init(authService: AuthService, syncService: SyncService, logoutUseCase: LogoutUseCase) {
        self.authService   = authService
        self.syncService   = syncService
        self.logoutUseCase = logoutUseCase
    }

    // MARK: - Profile

    func startEditProfile() {
        editName  = authService.currentUser?.name ?? ""
        editEmail = authService.currentUser?.email ?? ""
        isEditingProfile = true
    }

    func saveProfile() async {
        guard var user = authService.currentUser else { return }
        user = User(
            id: user.id,
            name: editName.trimmingCharacters(in: .whitespaces),
            email: user.email,    // email update requires re-auth in production
            avatarURL: user.avatarURL,
            isPremium: user.isPremium
        )
        isLoading = true
        do {
            try await authService.updateProfile(user)
            toastMessage = "Profile updated ✓"
        } catch {
            toastMessage = "Failed to update profile."
        }
        isLoading = false
        isEditingProfile = false
    }

    // MARK: - Theme

    func applyColorMode(_ mode: AppColorMode) {
        colorMode = mode
        ThemeManager.shared.setMode(mode)
    }

    // MARK: - Sync

    func triggerManualSync() async {
        await syncService.manualSync()
        toastMessage = syncService.status == .synced ? "Synced ✓" : "Sync failed"
    }

    // MARK: - Logout

    func logout() async {
        isLoading = true
        do {
            try await logoutUseCase.execute()
            try await authService.logout()
        } catch {
            toastMessage = "Logout failed. Try again."
        }
        isLoading = false
    }
}
