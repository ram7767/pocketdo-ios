// MARK: - File: Features/Auth/Views/AuthView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var vm: AuthViewModel = AuthViewModel(
        loginUseCase:  LoginUseCase(repository: AuthRepositoryImpl()),
        signupUseCase: SignupUseCase(repository: AuthRepositoryImpl()),
        guestUseCase:  GuestLoginUseCase(repository: AuthRepositoryImpl()),
        logoutUseCase: LogoutUseCase(repository: AuthRepositoryImpl()),
        authService:   AuthService(repository: AuthRepositoryImpl())
    )

    @EnvironmentObject var authService: AuthService
    @State private var showSignup: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Adaptive background
                Color.appBackground.ignoresSafeArea()

                // Hero gradient bleed
                VStack {
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.15), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .frame(height: 320)
                    .ignoresSafeArea()
                    Spacer()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: Header
                        headerSection
                            .padding(.top, AppSpacing.xxxl)
                            .padding(.bottom, AppSpacing.xl)

                        // MARK: Form Card
                        VStack(spacing: AppSpacing.md) {
                            formFields

                            if let error = vm.errorMessage {
                                errorBanner(error)
                            }

                            // Hint for mock credentials
                            hintCard

                            PrimaryButton("Log In", icon: "arrow.right", isLoading: vm.isLoading) {
                                Task { await performLogin() }
                            }

                            orDivider

                            socialButtons

                            orDivider

                            GhostButton("Continue as Guest", icon: "person.fill.questionmark") {
                                Task { await performGuestLogin() }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous))
                        .appShadow(.sheet)
                        .padding(.horizontal, AppSpacing.lg)

                        // MARK: Footer
                        signupLink
                            .padding(.top, AppSpacing.lg)
                            .padding(.bottom, AppSpacing.xxxl)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignup) {
                SignupView()
                    .environmentObject(authService)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppGradients.primaryCTA)
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.appOnPrimary)
            }
            .appShadow(.float)

            Text("PocketDo")
                .font(AppTypography.headlineLg)
                .foregroundStyle(Color.appOnSurface)

            Text("Your focused daily planner")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
    }

    // MARK: - Form

    private var formFields: some View {
        VStack(spacing: AppSpacing.sm) {
            AppTextField(
                placeholder: "Email address",
                text: Binding(
                    get: { vm.email },
                    set: { vm.email = $0 }
                ),
                icon: "envelope",
                keyboardType: .emailAddress,
                errorMessage: vm.emailError
            )

            AppTextField(
                placeholder: "Password",
                text: Binding(
                    get: { vm.password },
                    set: { vm.password = $0 }
                ),
                isSecure: true,
                icon: "lock",
                errorMessage: vm.passwordError
            )

            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // TODO: Navigate to password reset
                }
                .font(AppTypography.labelMd)
                .foregroundStyle(Color.appPrimary)
            }
        }
    }

    // MARK: - Hint

    private var hintCard: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.appPrimary)
                .font(.system(size: 13))
            Text("Demo: demo@pocketdo.app / password123")
                .font(AppTypography.labelSm)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(Color.appPrimaryContainer.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    // MARK: - Social Buttons

    private var socialButtons: some View {
        HStack(spacing: AppSpacing.sm) {
            socialButton(icon: "g.circle.fill", label: "Google") {
                // TODO: Google Sign-In
            }
            socialButton(icon: "apple.logo", label: "Apple") {
                // TODO: Apple Sign-In
            }
        }
    }

    private func socialButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                Text(label).font(AppTypography.titleSm).fontWeight(.medium)
            }
            .foregroundStyle(Color.appOnSurface)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.appSurfaceLow)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack {
            Rectangle().fill(Color.appSurfaceVariant).frame(height: 1)
            Text("or").font(AppTypography.labelMd).foregroundStyle(Color.appOnSurfaceMuted)
            Rectangle().fill(Color.appSurfaceVariant).frame(height: 1)
        }
    }

    // MARK: - Signup Link

    private var signupLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
            Button("Sign up") { showSignup = true }
                .font(AppTypography.titleSm)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appPrimary)
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.appError)
            Text(message)
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurface)
            Spacer()
        }
        .padding(AppSpacing.sm)
        .background(Color.appError.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Actions

    private func performLogin() async {
        // Wire to environment authService
        let authVM = container.makeAuthViewModel()
        authVM.email = vm.email
        authVM.password = vm.password
        // Use environment authService directly for state propagation
        vm.isLoading = true
        do {
            try await authService.login(email: vm.email, password: vm.password)
        } catch let error as AppError {
            vm.errorMessage = error.errorDescription
            if error == .invalidCredentials { vm.passwordError = "Incorrect password." }
        } catch {
            vm.errorMessage = "An unexpected error occurred."
        }
        vm.isLoading = false
    }

    private func performGuestLogin() async {
        vm.isLoading = true
        do {
            try await authService.continueAsGuest()
        } catch {
            vm.errorMessage = "Could not continue as guest."
        }
        vm.isLoading = false
    }
}

#Preview {
    AuthView()
        .environmentObject(DependencyContainer())
        .environmentObject(AuthService(repository: AuthRepositoryImpl()))
}
