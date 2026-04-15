// MARK: - File: Features/Auth/ViewModels/AuthViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSignup: Bool = false

    // Field validation
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var nameError: String? = nil
    @Published var confirmError: String? = nil

    // MARK: - Dependencies
    private let loginUseCase:  LoginUseCase
    private let signupUseCase: SignupUseCase
    private let guestUseCase:  GuestLoginUseCase
    private let logoutUseCase: LogoutUseCase
    let authService: AuthService

    // MARK: - Init
    init(
        loginUseCase: LoginUseCase,
        signupUseCase: SignupUseCase,
        guestUseCase: GuestLoginUseCase,
        logoutUseCase: LogoutUseCase,
        authService: AuthService
    ) {
        self.loginUseCase  = loginUseCase
        self.signupUseCase = signupUseCase
        self.guestUseCase  = guestUseCase
        self.logoutUseCase = logoutUseCase
        self.authService   = authService
    }

    // MARK: - Actions

    func login() async {
        clearErrors()
        guard validateLoginFields() else { return }
        isLoading = true
        do {
            try await authService.login(email: email, password: password)
        } catch let error as AppError {
            errorMessage = error.errorDescription
            if error == .invalidCredentials { passwordError = "Incorrect password." }
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        isLoading = false
    }

    func signup() async {
        clearErrors()
        guard validateSignupFields() else { return }
        isLoading = true
        do {
            try await authService.signup(name: name, email: email, password: password)
        } catch let error as AppError {
            errorMessage = error.errorDescription
            if error == .emailAlreadyInUse { emailError = "This email is already registered." }
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        isLoading = false
    }

    func continueAsGuest() async {
        isLoading = true
        do {
            try await authService.continueAsGuest()
        } catch {
            errorMessage = "Could not continue as guest. Try again."
        }
        isLoading = false
    }

    func logout() async {
        isLoading = true
        try? await logoutUseCase.execute()
        try? await authService.logout()
        isLoading = false
    }

    // MARK: - Validation

    private func validateLoginFields() -> Bool {
        var valid = true
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Email is required."; valid = false
        } else if !email.contains("@") {
            emailError = "Enter a valid email."; valid = false
        }
        if password.isEmpty {
            passwordError = "Password is required."; valid = false
        }
        return valid
    }

    private func validateSignupFields() -> Bool {
        var valid = true
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Name is required."; valid = false
        }
        if email.trimmingCharacters(in: .whitespaces).isEmpty || !email.contains("@") {
            emailError = "Enter a valid email."; valid = false
        }
        if password.count < 8 {
            passwordError = "Minimum 8 characters."; valid = false
        }
        if confirmPassword != password {
            confirmError = "Passwords do not match."; valid = false
        }
        return valid
    }

    private func clearErrors() {
        emailError = nil; passwordError = nil
        nameError = nil; confirmError = nil
        errorMessage = nil
    }
}
