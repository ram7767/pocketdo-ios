// MARK: - File: Domain/Repositories/RepositoryProtocols.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Task Repository

protocol TaskRepository {
    func fetchAll() async throws -> [TodoTask]
    func fetchPending() async throws -> [TodoTask]
    func fetchCompleted() async throws -> [TodoTask]
    func fetchByTag(_ tag: Tag) async throws -> [TodoTask]
    func search(query: String, tagIDs: [String]) async throws -> [TodoTask]
    func add(_ task: TodoTask) async throws
    func update(_ task: TodoTask) async throws
    func delete(id: String) async throws
    func markCompleted(id: String) async throws
    func syncTasks() async throws
    func unsyncedCount() async throws -> Int
}

// MARK: - Tag Repository

protocol TagRepository {
    func fetchAll() async throws -> [Tag]
    func add(_ tag: Tag) async throws
    func delete(id: String) async throws
}

// MARK: - Auth Repository

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func signup(name: String, email: String, password: String) async throws -> User
    func continueAsGuest() async throws -> User
    func logout() async throws
    func currentUser() async throws -> User?
    func updateProfile(_ user: User) async throws -> User
    func changePassword(current: String, new: String) async throws
}

// MARK: - User Repository

protocol UserRepository {
    func fetchProfile(id: String) async throws -> User
    func updateProfile(_ user: User) async throws -> User
    func deleteAccount(id: String) async throws
}

// MARK: - Local Data Source Protocol

protocol LocalTaskDataSource {
    func fetchAll() throws -> [TodoTask]
    func insert(_ task: TodoTask) throws
    func update(_ task: TodoTask) throws
    func delete(id: String) throws
    func markCompleted(id: String) throws
    /// Search tasks by title query and/or tag IDs. Empty arrays/strings mean "no filter".
    func search(query: String, tagIDs: [String]) throws -> [TodoTask]
}

// MARK: - Local Tag Data Source Protocol

protocol LocalTagDataSource {
    func fetchAll() throws -> [Tag]
    func insert(_ tag: Tag) throws
    func delete(id: String) throws
}

// MARK: - Remote Data Source Protocol

protocol RemoteTaskDataSource {
    func fetchAll(userId: String) async throws -> [TodoTask]
    func upload(_ task: TodoTask, userId: String) async throws
    func delete(id: String, userId: String) async throws
    func sync(tasks: [TodoTask], userId: String) async throws -> [TodoTask]
}

// MARK: - Subscription Repository

protocol SubscriptionRepository {
    func availablePlans() -> [SubscriptionPlan]
    func currentStatus() async throws -> Bool    // isPremium
    func purchase(plan: SubscriptionPlan) async throws
    func restorePurchases() async throws -> Bool
}


