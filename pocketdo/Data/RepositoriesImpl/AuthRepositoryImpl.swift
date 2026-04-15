// MARK: - File: Data/RepositoriesImpl/AuthRepositoryImpl.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private var currentSession: User? = nil

    // MARK: - Login

    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock credentials check
        guard email.lowercased() == "demo@pocketdo.app" && password == "password123" else {
            throw AppError.invalidCredentials
        }
        let user = User(
            id: "user-001",
            name: "Rama Narasimha",
            email: email,
            isPremium: false
        )
        currentSession = user
        return user
    }

    // MARK: - Signup

    func signup(name: String, email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        // Mock: check if email "exists"
        if email.lowercased() == "taken@pocketdo.app" {
            throw AppError.emailAlreadyInUse
        }
        let user = User(id: UUID().uuidString, name: name, email: email)
        currentSession = user
        return user
    }

    // MARK: - Guest

    func continueAsGuest() async throws -> User {
        try await Task.sleep(nanoseconds: 300_000_000)
        let guest = User(
            id: "guest-\(UUID().uuidString.prefix(8))",
            name: "Guest",
            email: "guest@pocketdo.app"
        )
        currentSession = guest
        return guest
    }

    // MARK: - Logout

    func logout() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        currentSession = nil
    }

    // MARK: - Current User

    func currentUser() async throws -> User? {
        return currentSession
    }

    // MARK: - Update Profile

    func updateProfile(_ user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        currentSession = user
        return user
    }

    // MARK: - Change Password

    func changePassword(current: String, new: String) async throws {
        try await Task.sleep(nanoseconds: 600_000_000)
        guard current != new else {
            throw AppError.unknown(message: "New password must be different from current.")
        }
        guard new.count >= 8 else { throw AppError.weakPassword }
        // TODO: Call Firebase Auth updatePassword
    }
}
