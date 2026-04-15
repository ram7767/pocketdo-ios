// MARK: - File: Features/Settings/Views/SettingsView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var authService: AuthService
    @StateObject private var vm: SettingsViewModel = {
        let authRepo = AuthRepositoryImpl()
        let taskRepo = TaskRepositoryImpl(local: InMemoryTaskDataSource(), remote: FirebaseTaskDataSource())
        let auth = AuthService(repository: authRepo)
        let sync = SyncService(repository: taskRepo)
        return SettingsViewModel(
            authService: auth,
            syncService: sync,
            logoutUseCase: LogoutUseCase(repository: authRepo)
        )
    }()

    @State private var showPremium = false
    @State private var showCloudSync = false
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        profileCard
                        preferencesSection
                        cloudSection
                        accountSection

                        versionFooter
                    }
                    .screenPadding()
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPremium) {
                PremiumView()
                    .environmentObject(container)
            }
            .sheet(isPresented: $showCloudSync) {
                CloudSyncView()
                    .environmentObject(container)
            }
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    Task { await performLogout() }
                }
                Button("Cancel", role: .cancel) {}
            }
            .toast(message: $vm.toastMessage)
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        CardView {
            if vm.isEditingProfile {
                editProfileContent
            } else {
                displayProfileContent
            }
        }
    }

    private var displayProfileContent: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppGradients.primaryCTA)
                    .frame(width: 60, height: 60)
                Text(authService.currentUser?.initials ?? "?")
                    .font(AppTypography.headlineSm)
                    .foregroundStyle(Color.appOnPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(authService.currentUser?.name ?? "Guest")
                    .font(AppTypography.titleLg)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appOnSurface)
                Text(authService.currentUser?.email ?? "")
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnSurfaceVariant)

                if authService.isGuest {
                    Text("Guest Mode").font(AppTypography.labelSm).foregroundStyle(Color.priorityMedium)
                } else if authService.currentUser?.isPremium == true {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill").font(.system(size: 10)).foregroundStyle(Color.priorityMedium)
                        Text("Premium").font(AppTypography.labelSm).foregroundStyle(Color.priorityMedium)
                    }
                }
            }

            Spacer()

            Button { vm.startEditProfile() } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }

    private var editProfileContent: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Edit Profile")
                .font(AppTypography.titleMd)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appOnSurface)
                .frame(maxWidth: .infinity, alignment: .leading)

            AppTextField(placeholder: "Name", text: $vm.editName, icon: "person")

            HStack(spacing: AppSpacing.sm) {
                Button("Cancel") { vm.isEditingProfile = false }
                    .font(AppTypography.titleSm)
                    .foregroundStyle(Color.appOnSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.appSurfaceVariant)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))

                PrimaryButton("Save", isLoading: vm.isLoading) {
                    Task { await vm.saveProfile() }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Preferences")
                .font(AppTypography.labelMd)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appOnSurfaceMuted)
                .padding(.horizontal, AppSpacing.xs)

            CardView {
                VStack(spacing: 0) {
                    // Theme
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            settingIcon("circle.lefthalf.filled", color: .appPrimary)
                            Text("Appearance").font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                            Spacer()
                        }

                        HStack(spacing: AppSpacing.xs) {
                            ForEach(AppColorMode.allCases) { mode in
                                Button {
                                    vm.applyColorMode(mode)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: mode.icon).font(.system(size: 12))
                                        Text(mode.label).font(AppTypography.labelMd).fontWeight(.medium)
                                    }
                                    .foregroundStyle(vm.colorMode == mode ? Color.appOnPrimary : Color.appOnSurfaceVariant)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(vm.colorMode == mode ? Color.appPrimary : Color.appSurfaceVariant)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .animation(.spring(response: 0.3), value: vm.colorMode)
                            }
                        }
                    }

                    settingDivider

                    // Notifications
                    Toggle(isOn: $vm.notificationsEnabled) {
                        HStack(spacing: AppSpacing.sm) {
                            settingIcon("bell.fill", color: .priorityMedium)
                            Text("Notifications").font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                        }
                    }
                    .tint(Color.appPrimary)

                    settingDivider

                    // Language
                    HStack {
                        settingIcon("globe", color: .appSecondary)
                        Text("Language").font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                        Spacer()
                        Menu {
                            ForEach(vm.availableLanguages, id: \.self) { lang in
                                Button(lang) { vm.selectedLanguage = lang }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(vm.selectedLanguage).font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurfaceVariant)
                                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(Color.appOnSurfaceMuted)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cloud

    private var cloudSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Cloud & Premium")
                .font(AppTypography.labelMd)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appOnSurfaceMuted)
                .padding(.horizontal, AppSpacing.xs)

            CardView {
                VStack(spacing: 0) {
                    settingsRow(icon: "icloud.fill", color: .appPrimary, label: "Cloud Sync") {
                        showCloudSync = true
                    }
                    settingDivider
                    settingsRow(icon: "crown.fill", color: .priorityMedium, label: "Go Premium") {
                        showPremium = true
                    }
                }
            }
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Account")
                .font(AppTypography.labelMd)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appOnSurfaceMuted)
                .padding(.horizontal, AppSpacing.xs)

            CardView {
                VStack(spacing: 0) {
                    settingsRow(icon: "lock.rotation", color: .appSecondary, label: "Change Password") {
                        // TODO: Show change password sheet
                    }
                    settingDivider
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            settingIcon("arrow.right.square.fill", color: .appError)
                            Text("Log Out")
                                .font(AppTypography.bodyMd)
                                .foregroundStyle(Color.appError)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Footer

    private var versionFooter: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text("PocketDo")
                .font(AppTypography.titleSm)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appPrimary)
            Text("Version 1.0.0 (1) · Built with ♥")
                .font(AppTypography.labelSm)
                .foregroundStyle(Color.appOnSurfaceMuted)
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                settingIcon(icon, color: color)
                Text(label).font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Color.appOnSurfaceMuted)
            }
        }
        .buttonStyle(.plain)
    }

    private func settingIcon(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: name)
                .font(.system(size: 14))
                .foregroundStyle(color)
        }
    }

    private var settingDivider: some View {
        Divider()
            .background(Color.appSurfaceVariant)
            .padding(.vertical, AppSpacing.xs)
    }

    private func performLogout() async {
        await vm.logout()
        try? await authService.logout()
    }
}

#Preview {
    SettingsView()
        .environmentObject(DependencyContainer())
        .environmentObject(AuthService(repository: AuthRepositoryImpl()))
}
