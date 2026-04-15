// MARK: - File: Domain/UseCases/AuthUseCases.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

// MARK: - Login Use Case

struct LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> User {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(trimmedEmail) else {
            throw AppError.unknown(message: "Please enter a valid email address.")
        }
        guard password.count >= 6 else {
            throw AppError.weakPassword
        }
        return try await repository.login(email: trimmedEmail, password: password)
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}

// MARK: - Signup Use Case

struct SignupUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(name: String, email: String, password: String, confirmPassword: String) async throws -> User {
        let trimmedName  = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            throw AppError.unknown(message: "Please enter your name.")
        }
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            throw AppError.unknown(message: "Please enter a valid email address.")
        }
        guard password.count >= 8 else {
            throw AppError.weakPassword
        }
        guard password == confirmPassword else {
            throw AppError.unknown(message: "Passwords do not match.")
        }
        return try await repository.signup(name: trimmedName, email: trimmedEmail, password: password)
    }
}

// MARK: - Guest Login Use Case

struct GuestLoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async throws -> User {
        try await repository.continueAsGuest()
    }
}

// MARK: - Logout Use Case

struct LogoutUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.logout()
    }
}
