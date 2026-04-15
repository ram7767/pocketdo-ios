// MARK: - File: Features/Dashboard/Views/DashboardView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var authService: AuthService
    @StateObject private var vm: DashboardViewModel = {
        let repo = TaskRepositoryImpl(local: InMemoryTaskDataSource(), remote: FirebaseTaskDataSource())
        return DashboardViewModel(
            fetchTasksUseCase: FetchTasksUseCase(repository: repo),
            statsUseCase: DashboardStatsUseCase(repository: repo)
        )
    }()

    @State private var showAddTask = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        // Header
                        dashboardHeader
                            .padding(.top, AppSpacing.lg)

                        // Internal Tabs (Activity / Upcoming / History)
                        tabSelector
                            .padding(.top, AppSpacing.md)

                        // Tab content
                        tabContent
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, 120) // FAB clearance
                    }
                    .screenPadding()
                }
                .refreshable { await vm.refresh() }
            }
        }
        .task { await vm.loadAll() }
    }

    // MARK: - Header

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(greetingText)
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)

            Text(authService.currentUser?.name.components(separatedBy: " ").first ?? "There")
                .font(AppTypography.headlineLg)
                .foregroundStyle(Color.appOnSurface)

            Text(Date().fullDateTimeString.components(separatedBy: " at").first ?? "")
                .font(AppTypography.labelMd)
                .foregroundStyle(Color.appOnSurfaceMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤"
        case 17..<21: return "Good evening 🌅"
        default:      return "Good night 🌙"
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(DashboardViewModel.DashboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) { vm.selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(AppTypography.titleSm)
                        .fontWeight(vm.selectedTab == tab ? .semibold : .regular)
                        .foregroundStyle(vm.selectedTab == tab ? Color.appOnPrimary : Color.appOnSurfaceVariant)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            vm.selectedTab == tab
                                ? AnyShapeStyle(AppGradients.primaryCTA)
                                : AnyShapeStyle(Color.appSurfaceVariant)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3), value: vm.selectedTab)
            }
            Spacer()
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        if vm.isLoading {
            loadingState
        } else {
            switch vm.selectedTab {
            case .activity: activityTab
            case .upcoming: upcomingTab
            case .history:  historyTab
            }
        }
    }

    // MARK: - Activity Tab

    private var activityTab: some View {
        VStack(spacing: AppSpacing.lg) {
            // Stats Row
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                StatCard(
                    title: "Completed",
                    value: "\(vm.stats.completed)",
                    icon: "checkmark.circle.fill",
                    color: .appSecondary,
                    trend: "Today: \(vm.stats.completedToday)"
                )
                StatCard(
                    title: "Pending",
                    value: "\(vm.stats.pending)",
                    icon: "clock.fill",
                    color: .priorityMedium
                )
                StatCard(
                    title: "Overdue",
                    value: "\(vm.stats.overdue)",
                    icon: "exclamationmark.circle.fill",
                    color: .appError
                )
            }

            // Pie Chart
            if !vm.chartData.isEmpty {
                chartSection
            }

            // Active tasks
            if !vm.activeTasks.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    SectionHeader(title: "In Focus")
                    ForEach(vm.activeTasks) { task in
                        TaskRow(task: task)
                    }
                }
            } else {
                EmptyStateView(
                    icon: "tray.fill",
                    title: "No active tasks",
                    subtitle: "Tap + to add your first task for today."
                )
            }
        }
    }

    // MARK: - Chart

    private var chartSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(title: "Task Breakdown")

                HStack(spacing: AppSpacing.lg) {
                    // Pie Chart
                    Chart(vm.chartData) { slice in
                        SectorMark(
                            angle: .value("Count", slice.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 130, height: 130)

                    // Legend
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        ForEach(vm.chartData) { slice in
                            HStack(spacing: AppSpacing.xs) {
                                Circle().fill(slice.color).frame(width: 8, height: 8)
                                Text(slice.label).font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurfaceVariant)
                                Spacer()
                                Text("\(slice.count)").font(AppTypography.titleSm).fontWeight(.semibold).foregroundStyle(Color.appOnSurface)
                            }
                        }

                        Divider().background(Color.appSurfaceVariant)

                        HStack {
                            Text("Total").font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurfaceVariant)
                            Spacer()
                            Text("\(vm.stats.total)").font(AppTypography.titleSm).fontWeight(.bold).foregroundStyle(Color.appOnSurface)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Upcoming Tab

    private var upcomingTab: some View {
        VStack(spacing: AppSpacing.sm) {
            if vm.upcomingTasks.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.clock",
                    title: "Nothing upcoming",
                    subtitle: "Tasks with deadlines in the next 7 days will appear here."
                )
            } else {
                SectionHeader(title: "Next 7 Days")
                ForEach(vm.upcomingTasks) { task in
                    TaskRow(task: task)
                }
            }
        }
    }

    // MARK: - History Tab

    private var historyTab: some View {
        VStack(spacing: AppSpacing.md) {
            if vm.historyGrouped.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No history yet",
                    subtitle: "Completed tasks will appear here, grouped by date."
                )
            } else {
                ForEach(vm.historyGrouped, id: \.key) { group in
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(group.key)
                            .font(AppTypography.labelMd)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appOnSurfaceMuted)

                        ForEach(group.tasks) { task in
                            CompletedTaskRow(task: task)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(0..<4, id: \.self) { _ in SkeletonRow() }
        }
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let task: TodoTask

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Priority dot
            Circle()
                .fill(priorityColor)
                .frame(width: 10, height: 10)
                .padding(.leading, AppSpacing.xs)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppTypography.titleMd)
                    .foregroundStyle(Color.appOnSurface)
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xs) {
                    if let deadline = task.deadline {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundStyle(deadline.isOverdue ? Color.appError : Color.appOnSurfaceMuted)
                        Text(deadline.deadlineLabel)
                            .font(AppTypography.labelSm)
                            .foregroundStyle(deadline.isOverdue ? Color.appError : Color.appOnSurfaceMuted)
                    }
                    if !task.tags.isEmpty {
                        ForEach(task.tags.prefix(2)) { tag in
                            TagChip(tag: tag)
                        }
                    }
                }
            }

            Spacer()
            PriorityBadge(priority: task.priority)
        }
        .padding(AppSpacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        .appShadow(.card)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low:    return .priorityLow
        case .medium: return .priorityMedium
        case .high:   return .priorityHigh
        }
    }
}

// MARK: - Completed Task Row

struct CompletedTaskRow: View {
    let task: TodoTask

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.appSecondary)
                .font(.system(size: 20))

            Text(task.title)
                .font(AppTypography.bodyMd)
                .strikethrough(true, color: Color.appOnSurfaceMuted)
                .foregroundStyle(Color.appOnSurfaceVariant.opacity(0.6))
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
        .background(Color.appSurfaceDim.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .environmentObject(DependencyContainer())
        .environmentObject(AuthService(repository: AuthRepositoryImpl()))
}
