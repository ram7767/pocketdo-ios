// MARK: - File: Data/DataSources/Remote/RemoteTaskDataSource.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

final class FirebaseTaskDataSource: RemoteTaskDataSource {

    // MARK: - Fetch

    func fetchAll(userId: String) async throws -> [TodoTask] {
        // TODO: Replace with Firestore query
        // let db = Firestore.firestore()
        // let snapshot = try await db.collection("users").document(userId).collection("tasks").getDocuments()
        // return snapshot.documents.compactMap { try? $0.data(as: TodoTask.self) }
        try await Task.sleep(nanoseconds: 500_000_000) // simulate latency
        return []
    }

    // MARK: - Upload

    func upload(_ task: TodoTask, userId: String) async throws {
        // TODO: Replace with Firestore set
        // let db = Firestore.firestore()
        // try db.collection("users").document(userId).collection("tasks").document(task.id).setData(from: task)
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    // MARK: - Delete

    func delete(id: String, userId: String) async throws {
        // TODO: Replace with Firestore delete
        // try await Firestore.firestore().collection("users").document(userId).collection("tasks").document(id).delete()
        try await Task.sleep(nanoseconds: 200_000_000)
    }

    // MARK: - Sync

    func sync(tasks: [TodoTask], userId: String) async throws -> [TodoTask] {
        // TODO: Implement bidirectional sync strategy:
        // 1. Upload local unsynced tasks
        // 2. Fetch remote tasks
        // 3. Merge and resolve conflicts (last-write-wins or manual resolution)
        try await Task.sleep(nanoseconds: 800_000_000)
        return tasks
    }
}

// MARK: - API Client (Generic REST placeholder)

final class APIClient {
    static let shared = APIClient()
    private let baseURL: String

    private init() {
        // Set base URL from Constants or env config
        self.baseURL = "https://api.pocketdo.app/v1"
    }

    func get<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw AppError.unknown(message: "Invalid URL.")
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AppError.serverError(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func post<T: Encodable>(path: String, body: T) async throws {
        guard let url = URL(string: baseURL + path) else {
            throw AppError.unknown(message: "Invalid URL.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AppError.serverError(code: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
    }
}
