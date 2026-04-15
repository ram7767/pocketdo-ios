// MARK: - File: Domain/UseCases/TaskUseCases.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Fetch Tasks Use Case

struct FetchTasksUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute() async throws -> [TodoTask] {
        try await repository.fetchAll()
    }

    func executePending() async throws -> [TodoTask] {
        try await repository.fetchPending()
    }

    func executeCompleted() async throws -> [TodoTask] {
        try await repository.fetchCompleted()
    }

    func executeUpcoming(days: Int = 7) async throws -> [TodoTask] {
        let all = try await repository.fetchPending()
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return all
            .filter { task in
                guard let deadline = task.deadline else { return false }
                return deadline <= cutoff && deadline >= Date()
            }
            .sorted { ($0.deadline ?? Date.distantFuture) < ($1.deadline ?? Date.distantFuture) }
    }
}

// MARK: - Add Task Use Case

struct AddTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(
        title: String,
        description: String = "",
        priority: Priority = .medium,
        deadline: Date? = nil,
        tags: [Tag] = [],
        attachments: [TaskAttachment] = []
    ) async throws -> TodoTask {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown(message: "Task title cannot be empty.")
        }
        let task = TodoTask(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description,
            priority: priority,
            tags: tags,
            deadline: deadline,
            attachments: attachments
        )
        try await repository.add(task)
        return task
    }
}

// MARK: - Update Task Use Case

struct UpdateTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(_ task: TodoTask) async throws -> TodoTask {
        guard !task.title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.unknown(message: "Task title cannot be empty.")
        }
        var updated = task
        updated = TodoTask(
            id: task.id,
            title: task.title.trimmingCharacters(in: .whitespaces),
            description: task.description,
            priority: task.priority,
            status: task.status,
            tags: task.tags,
            deadline: task.deadline,
            attachments: task.attachments
        )
        try await repository.update(updated)
        return updated
    }

    func markCompleted(id: String) async throws {
        try await repository.markCompleted(id: id)
    }
}

// MARK: - Delete Task Use Case

struct DeleteTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.delete(id: id)
    }
}

// MARK: - Sync Tasks Use Case

struct SyncTasksUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.syncTasks()
    }

    func unsyncedCount() async throws -> Int {
        try await repository.unsyncedCount()
    }
}

// MARK: - Dashboard Stats Use Case

struct DashboardStatsUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute() async throws -> DashboardStats {
        let all = try await repository.fetchAll()
        let completed = all.filter { $0.status == .completed }
        let pending   = all.filter { $0.status == .pending && !($0.deadline.map { $0 < Date() } ?? false) }
        let overdue   = all.filter { $0.computedStatus == .overdue }

        let today = Calendar.current.startOfDay(for: Date())
        let completedToday = completed.filter {
            guard let completedAt = $0.completedAt else { return false }
            return completedAt >= today
        }

        return DashboardStats(
            total: all.count,
            completed: completed.count,
            pending: pending.count,
            overdue: overdue.count,
            completedToday: completedToday.count
        )
    }
}

struct DashboardStats {
    let total: Int
    let completed: Int
    let pending: Int
    let overdue: Int
    let completedToday: Int

    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}
