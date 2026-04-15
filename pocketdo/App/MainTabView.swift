// MARK: - File: App/MainTabView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

// MARK: - AppTab

enum AppTab: Int, CaseIterable {
    case dashboard = 0
    case search    = 1
    case settings  = 2
}

// MARK: - MainTabView

struct MainTabView: View {
    @EnvironmentObject var container: DependencyContainer
    @State private var selectedTab: AppTab = .dashboard
    @State private var showAddTask: Bool   = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(AppTab.dashboard)

                SearchView(vm: container.makeSearchViewModel())
                    .tag(AppTab.search)

                SettingsView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Glass Tab Bar
            glassTabBar
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskView(isPresented: $showAddTask)
                .environmentObject(container)
        }
        .ignoresSafeArea(.keyboard)
    }

    // ─────────────────────────────────────
    // MARK: - Glass Tab Bar
    // ─────────────────────────────────────

    private var glassTabBar: some View {
        HStack(spacing: 0) {
            tabButton(tab: .dashboard, icon: "rectangle.3.group.fill", label: "Dashboard")
                .accessibilityIdentifier("tab_dashboard")

            // FAB Center
            FABButton { showAddTask = true }
                .padding(.horizontal, AppSpacing.md)
                .accessibilityIdentifier("fab_addTask")

            tabButton(tab: .search, icon: "magnifyingglass", label: "Search")
                .accessibilityIdentifier("tab_search")

            tabButton(tab: .settings, icon: "gearshape.fill", label: "Settings")
                .accessibilityIdentifier("tab_settings")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .appShadow(.float)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }

    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedTab = tab }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.12))
                            .frame(width: 40, height: 40)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.appOnSurfaceVariant)
                }
                Text(label)
                    .font(AppTypography.labelSm)
                    .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.appOnSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: selectedTab)
    }
}
