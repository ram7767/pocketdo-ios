// MARK: - File: Data/RepositoriesImpl/TaskRepositoryImpl.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

final class TaskRepositoryImpl: TaskRepository {
    private let local: LocalTaskDataSource
    private let remote: RemoteTaskDataSource
    private var userId: String?

    init(local: LocalTaskDataSource, remote: RemoteTaskDataSource, userId: String? = nil) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    func setUser(_ id: String) {
        self.userId = id
    }

    // MARK: - Fetch

    func fetchAll() async throws -> [TodoTask] {
        do {
            return try local.fetchAll()
        } catch {
            throw AppError.fetchFailed
        }
    }

    func fetchPending() async throws -> [TodoTask] {
        let all = try await fetchAll()
        return all.filter { $0.status != .completed }
    }

    func fetchCompleted() async throws -> [TodoTask] {
        let all = try await fetchAll()
        return all.filter { $0.status == .completed }
    }

    func fetchByTag(_ tag: Tag) async throws -> [TodoTask] {
        let all = try await fetchAll()
        return all.filter { $0.tags.contains(tag) }
    }

    func search(query: String, tagIDs: [String]) async throws -> [TodoTask] {
        do {
            return try local.search(query: query, tagIDs: tagIDs)
        } catch {
            throw AppError.fetchFailed
        }
    }

    // MARK: - Write

    func add(_ task: TodoTask) async throws {
        do {
            try local.insert(task)
        } catch {
            throw AppError.saveFailed
        }
    }

    func update(_ task: TodoTask) async throws {
        do {
            try local.update(task)
        } catch {
            throw AppError.saveFailed
        }
    }

    func delete(id: String) async throws {
        do {
            try local.delete(id: id)
        } catch {
            throw AppError.deleteFailed
        }
    }

    func markCompleted(id: String) async throws {
        do {
            try local.markCompleted(id: id)
        } catch {
            throw AppError.saveFailed
        }
    }

    // MARK: - Sync

    func syncTasks() async throws {
        guard let userId else { throw AppError.unauthorized }
        let localTasks = try local.fetchAll()
        let synced = try await remote.sync(tasks: localTasks, userId: userId)
        // Update local with any server-side changes
        for task in synced {
            try? local.update(task)
        }
    }

    func unsyncedCount() async throws -> Int {
        let all = try local.fetchAll()
        return all.filter { !$0.isSynced }.count
    }
}
