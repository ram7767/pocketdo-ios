// MARK: - File: Services/AppServices.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation
import Combine

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var isGuest: Bool = false

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func login(email: String, password: String) async throws {
        let user = try await repository.login(email: email, password: password)
        currentUser = user
        isAuthenticated = true
        isGuest = false
    }

    func signup(name: String, email: String, password: String) async throws {
        let user = try await repository.signup(name: name, email: email, password: password)
        currentUser = user
        isAuthenticated = true
        isGuest = false
    }

    func continueAsGuest() async throws {
        let user = try await repository.continueAsGuest()
        currentUser = user
        isAuthenticated = true
        isGuest = true
    }

    func logout() async throws {
        try await repository.logout()
        currentUser = nil
        isAuthenticated = false
        isGuest = false
    }

    func updateProfile(_ user: User) async throws {
        let updated = try await repository.updateProfile(user)
        currentUser = updated
    }
}

// MARK: - Sync Service

@MainActor
final class SyncService: ObservableObject {
    @Published var status: SyncStatus = .offline
    @Published var lastSyncedAt: Date? = nil
    @Published var autoSyncEnabled: Bool = true

    private let repository: TaskRepository
    private var syncTimer: Timer?

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func manualSync() async {
        guard status != .syncing else { return }
        status = .syncing
        do {
            try await repository.syncTasks()
            lastSyncedAt = Date()
            status = .synced
        } catch {
            status = .failed
        }
    }

    func startAutoSync(interval: TimeInterval = 300) {
        guard autoSyncEnabled else { return }
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.manualSync()
            }
        }
    }

    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }

    func toggleAutoSync(_ enabled: Bool) {
        autoSyncEnabled = enabled
        if enabled {
            startAutoSync()
        } else {
            stopAutoSync()
        }
    }
}

// MARK: - Subscription Service (StoreKit 2 Placeholder)

@MainActor
final class SubscriptionService: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var isProcessing: Bool = false

    static let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "pocketdo.premium.monthly",
            name: "Monthly",
            price: "$2.99",
            period: "month",
            savings: nil,
            isRecommended: false,
            features: [
                "Cloud backup & sync",
                "Unlimited tasks",
                "Advanced analytics",
                "Priority support"
            ]
        ),
        SubscriptionPlan(
            id: "pocketdo.premium.yearly",
            name: "Yearly",
            price: "$19.99",
            period: "year",
            savings: "Save 44%",
            isRecommended: true,
            features: [
                "Cloud backup & sync",
                "Unlimited tasks",
                "Advanced analytics",
                "Priority support",
                "Early access to new features"
            ]
        )
    ]

    func purchase(plan: SubscriptionPlan) async throws {
        isProcessing = true
        defer { isProcessing = false }
        // TODO: Implement with StoreKit 2
        // let product = try await Product.products(for: [plan.id]).first
        // let result = try await product?.purchase()
        // Handle .success, .pending, .userCancelled
        try await Task.sleep(nanoseconds: 1_500_000_000)
        isPremium = true  // Mock success
    }

    func restorePurchases() async throws {
        isProcessing = true
        defer { isProcessing = false }
        // TODO: AppStore.sync()
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
