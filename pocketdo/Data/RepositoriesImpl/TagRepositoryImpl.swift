// MARK: - File: Data/RepositoriesImpl/TagRepositoryImpl.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - TagRepositoryImpl

final class TagRepositoryImpl: TagRepository {
    private let local: LocalTagDataSource

    init(local: LocalTagDataSource) {
        self.local = local
    }

    func fetchAll() async throws -> [Tag] {
        do {
            return try local.fetchAll()
        } catch {
            throw AppError.fetchFailed
        }
    }

    func add(_ tag: Tag) async throws {
        do {
            try local.insert(tag)
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
}
