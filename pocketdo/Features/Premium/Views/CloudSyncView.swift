// MARK: - File: Features/Premium/Views/CloudSyncView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct CloudSyncView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var syncService = SyncService(
        repository: TaskRepositoryImpl(local: InMemoryTaskDataSource(), remote: FirebaseTaskDataSource())
    )
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        statusCard
                        actionsCard
                        infoCard
                    }
                    .screenPadding()
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxxl)
                }
            }
            .navigationTitle("Cloud Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.appOnSurfaceVariant)
                    }
                }
            }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                // Large sync icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: syncIcon)
                        .font(.system(size: 36))
                        .foregroundStyle(statusColor)
                        .symbolEffect(.bounce, value: syncService.status == .syncing)
                }

                Text(syncService.status.rawValue)
                    .font(AppTypography.headlineSm)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appOnSurface)

                if let lastSynced = syncService.lastSyncedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 11))
                        Text("Last synced: \(lastSynced.fullDateTimeString)")
                            .font(AppTypography.labelMd)
                    }
                    .foregroundStyle(Color.appOnSurfaceMuted)
                } else {
                    Text("Never synced")
                        .font(AppTypography.labelMd)
                        .foregroundStyle(Color.appOnSurfaceMuted)
                }

                SyncStatusBadge(status: syncService.status)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
        }
    }

    // MARK: - Actions Card

    private var actionsCard: some View {
        CardView {
            VStack(spacing: AppSpacing.sm) {
                // Manual sync
                PrimaryButton(
                    syncService.status == .syncing ? "Syncing…" : "Sync Now",
                    icon: "arrow.triangle.2.circlepath",
                    isLoading: syncService.status == .syncing
                ) {
                    Task { await syncService.manualSync() }
                }

                // Auto-sync toggle
                Toggle(isOn: Binding(
                    get: { syncService.autoSyncEnabled },
                    set: { syncService.toggleAutoSync($0) }
                )) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundStyle(Color.appPrimary)
                            .font(.system(size: 18))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-Sync").font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                            Text("Sync every 5 minutes").font(AppTypography.labelSm).foregroundStyle(Color.appOnSurfaceMuted)
                        }
                    }
                }
                .tint(Color.appPrimary)
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        CardView(background: .appPrimaryContainer.opacity(0.4)) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "info.circle.fill").foregroundStyle(Color.appPrimary)
                    Text("How Cloud Sync Works").font(AppTypography.titleSm).fontWeight(.semibold).foregroundStyle(Color.appOnSurface)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    infoRow(icon: "arrow.up.arrow.down", text: "Your tasks are securely synced to our servers")
                    infoRow(icon: "iphone.and.arrow.forward.to.iphone", text: "Access your tasks on all your devices")
                    infoRow(icon: "lock.shield.fill", text: "End-to-end encrypted — only you can read your data")
                    infoRow(icon: "wifi.slash", text: "Works offline — syncs automatically when connected")
                }
            }
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 18)
            Text(text)
                .font(AppTypography.bodySm)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
    }

    // MARK: - Computed

    private var statusColor: Color {
        switch syncService.status {
        case .synced:   return .appSecondary
        case .syncing:  return .appPrimary
        case .pending:  return .priorityMedium
        case .failed:   return .appError
        case .offline:  return .appOnSurfaceMuted
        }
    }

    private var syncIcon: String {
        switch syncService.status {
        case .synced:   return "checkmark.icloud.fill"
        case .syncing:  return "arrow.triangle.2.circlepath.icloud.fill"
        case .pending:  return "icloud.fill"
        case .failed:   return "exclamationmark.icloud.fill"
        case .offline:  return "icloud.slash.fill"
        }
    }
}

#Preview {
    CloudSyncView()
        .environmentObject(DependencyContainer())
}
