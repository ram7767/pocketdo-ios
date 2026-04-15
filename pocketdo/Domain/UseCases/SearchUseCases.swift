// MARK: - File: Domain/UseCases/SearchUseCases.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Search Tasks Use Case

/// Searches tasks by title text and/or by selected tag IDs.
/// - An empty `query` matches all titles.
/// - An empty `tagIDs` array means no tag filter is applied.
/// - When both are set, the result is the intersection (AND logic).
struct SearchTasksUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(query: String, tagIDs: [String]) async throws -> [TodoTask] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        return try await repository.search(query: trimmed, tagIDs: tagIDs)
    }
}

// MARK: - Fetch All Tags Use Case

/// Fetches all unique tags stored in the repository (used to populate filter chips).
struct FetchAllTagsUseCase {
    private let repository: TagRepository

    init(repository: TagRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Tag] {
        try await repository.fetchAll()
    }
}
