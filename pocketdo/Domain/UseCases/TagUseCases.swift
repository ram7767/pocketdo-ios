// MARK: - File: Domain/UseCases/TagUseCases.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Add Tag Use Case

struct AddTagUseCase {
    private let repository: TagRepository

    init(repository: TagRepository) {
        self.repository = repository
    }

    func execute(name: String, colorHex: String = "#3525CD") async throws -> Tag {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw AppError.unknown(message: "Tag name cannot be empty.")
        }
        let tag = Tag(name: trimmed, colorHex: colorHex)
        try await repository.add(tag)
        return tag
    }
}

// MARK: - Delete Tag Use Case

struct DeleteTagUseCase {
    private let repository: TagRepository

    init(repository: TagRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.delete(id: id)
    }
}
