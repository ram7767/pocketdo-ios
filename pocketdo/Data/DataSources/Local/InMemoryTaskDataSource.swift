// MARK: - File: Data/DataSources/Local/InMemoryTaskDataSource.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

final class InMemoryTaskDataSource: LocalTaskDataSource {
    private var store: [TodoTask]

    init(seed: [TodoTask] = TodoTask.mockTasks) {
        self.store = seed
    }

    func fetchAll() throws -> [TodoTask] {
        store.sorted { $0.createdAt > $1.createdAt }
    }

    func insert(_ task: TodoTask) throws {
        guard !store.contains(where: { $0.id == task.id }) else { return }
        store.append(task)
    }

    func update(_ task: TodoTask) throws {
        guard let idx = store.firstIndex(where: { $0.id == task.id }) else {
            throw AppError.fetchFailed
        }
        store[idx] = task
    }

    func delete(id: String) throws {
        guard store.contains(where: { $0.id == id }) else {
            throw AppError.deleteFailed
        }
        store.removeAll { $0.id == id }
    }

    func markCompleted(id: String) throws {
        guard let idx = store.firstIndex(where: { $0.id == id }) else {
            throw AppError.fetchFailed
        }
        var task = store[idx]
        task = TodoTask(
            id: task.id,
            title: task.title,
            description: task.description,
            priority: task.priority,
            status: .completed,
            tags: task.tags,
            deadline: task.deadline,
            attachments: task.attachments
        )
        store[idx] = task
    }

    func search(query: String, tagIDs: [String]) throws -> [TodoTask] {
        var results = store
        if !query.isEmpty {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }
        if !tagIDs.isEmpty {
            results = results.filter { task in
                task.tags.contains { tagIDs.contains($0.id) }
            }
        }
        return results.sorted { $0.createdAt > $1.createdAt }
    }
}
