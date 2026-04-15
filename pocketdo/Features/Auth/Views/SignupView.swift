// MARK: - File: Features/Auth/Views/SignupView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var nameError: String? = nil
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmError: String? = nil

    private let signupUseCase = SignupUseCase(repository: AuthRepositoryImpl())

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    headerSection

                    VStack(spacing: AppSpacing.sm) {
                        AppTextField(
                            placeholder: "Full name",
                            text: $name,
                            icon: "person",
                            errorMessage: nameError
                        )
                        AppTextField(
                            placeholder: "Email address",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            errorMessage: emailError
                        )
                        AppTextField(
                            placeholder: "Password (min. 8 characters)",
                            text: $password,
                            isSecure: true,
                            icon: "lock",
                            errorMessage: passwordError
                        )
                        AppTextField(
                            placeholder: "Confirm password",
                            text: $confirmPassword,
                            isSecure: true,
                            icon: "lock.fill",
                            errorMessage: confirmError
                        )
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous))
                    .appShadow(.card)

                    if let error = errorMessage {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.appError)
                            Text(error).font(AppTypography.bodyMd).foregroundStyle(Color.appOnSurface)
                            Spacer()
                        }
                        .padding(AppSpacing.sm)
                        .background(Color.appError.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    }

                    PrimaryButton("Create Account", icon: "sparkles", isLoading: isLoading) {
                        Task { await signup() }
                    }

                    Text("By signing up, you agree to our Terms of Service and Privacy Policy.")
                        .font(AppTypography.labelSm)
                        .foregroundStyle(Color.appOnSurfaceMuted)
                        .multilineTextAlignment(.center)
                }
                .screenPadding()
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Join PocketDo")
                .font(AppTypography.headlineMd)
                .foregroundStyle(Color.appOnSurface)
            Text("Start organizing your life today")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func signup() async {
        nameError = nil; emailError = nil; passwordError = nil; confirmError = nil; errorMessage = nil

        isLoading = true
        do {
            let user = try await signupUseCase.execute(
                name: name, email: email, password: password, confirmPassword: confirmPassword
            )
            try await authService.signup(name: user.name, email: user.email, password: password)
        } catch let err as AppError {
            switch err {
            case .emailAlreadyInUse: emailError = "This email is already registered."
            case .weakPassword:      passwordError = "Minimum 8 characters required."
            default:                 errorMessage = err.errorDescription
            }
        } catch {
            errorMessage = "Signup failed. Please try again."
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AuthService(repository: AuthRepositoryImpl()))
    }
}
