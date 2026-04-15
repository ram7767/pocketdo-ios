// MARK: - File: Features/Dashboard/ViewModels/DashboardViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published State
    @Published var tasks: [TodoTask] = []
    @Published var upcomingTasks: [TodoTask] = []
    @Published var completedTasks: [TodoTask] = []
    @Published var stats: DashboardStats = DashboardStats(total: 0, completed: 0, pending: 0, overdue: 0, completedToday: 0)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedTab: DashboardTab = .activity

    // MARK: - Dependencies
    private let fetchTasksUseCase: FetchTasksUseCase
    private let statsUseCase: DashboardStatsUseCase

    enum DashboardTab: String, CaseIterable {
        case activity = "Activity"
        case upcoming = "Upcoming"
        case history  = "History"
    }

    // MARK: - Init
    init(fetchTasksUseCase: FetchTasksUseCase, statsUseCase: DashboardStatsUseCase) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.statsUseCase = statsUseCase
    }

    // MARK: - Load

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        do {
            async let allTasks     = fetchTasksUseCase.execute()
            async let upcoming     = fetchTasksUseCase.executeUpcoming(days: 7)
            async let completed    = fetchTasksUseCase.executeCompleted()
            async let dashStats    = statsUseCase.execute()

            tasks          = try await allTasks
            upcomingTasks  = try await upcoming
            completedTasks = try await completed
            stats          = try await dashStats
        } catch let err as AppError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = "Failed to load tasks."
        }
        isLoading = false
    }

    func refresh() async {
        await loadAll()
    }

    // MARK: - Computed

    var activeTasks: [TodoTask] {
        tasks.filter { $0.status == .pending }.prefix(3).map { $0 }
    }

    var overdueTasks: [TodoTask] {
        tasks.filter { $0.computedStatus == .overdue }
    }

    /// Pie chart data
    var chartData: [ChartSlice] {
        [
            ChartSlice(label: "Completed", count: stats.completed, color: AppGradients.chartCompleted),
            ChartSlice(label: "Pending",   count: stats.pending,   color: AppGradients.chartPending),
            ChartSlice(label: "Overdue",   count: stats.overdue,   color: AppGradients.chartOverdue)
        ].filter { $0.count > 0 }
    }

    /// History grouped by date
    var historyGrouped: [(key: String, tasks: [TodoTask])] {
        let grouped = Dictionary(grouping: completedTasks) { task -> String in
            task.completedAt?.sectionHeaderString ?? task.updatedAt.sectionHeaderString
        }
        return grouped
            .map { (key: $0.key, tasks: $0.value.sorted { $0.updatedAt > $1.updatedAt }) }
            .sorted { lhs, rhs in
                let lhsDate = lhs.tasks.first?.completedAt ?? lhs.tasks.first?.updatedAt ?? Date.distantPast
                let rhsDate = rhs.tasks.first?.completedAt ?? rhs.tasks.first?.updatedAt ?? Date.distantPast
                return lhsDate > rhsDate
            }
    }
}

struct ChartSlice: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let color: Color
    var percentage: Double = 0
}
