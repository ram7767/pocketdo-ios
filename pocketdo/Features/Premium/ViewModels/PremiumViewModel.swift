// MARK: - File: Features/Premium/ViewModels/PremiumViewModel.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

@MainActor
final class PremiumViewModel: ObservableObject {

    // MARK: - Published State
    @Published var selectedPlan: SubscriptionPlan? = nil
    @Published var isPurchasing: Bool = false
    @Published var isRestoring: Bool = false
    @Published var toastMessage: String? = nil
    @Published var showSuccessSheet: Bool = false

    // MARK: - Dependencies
    let subscriptionService: SubscriptionService

    var plans: [SubscriptionPlan] { SubscriptionService.plans }
    var isPremium: Bool { subscriptionService.isPremium }

    // MARK: - Init
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
        self.selectedPlan = plans.first { $0.isRecommended } ?? plans.first
    }

    // MARK: - Actions

    func purchase() async {
        guard let plan = selectedPlan else { return }
        isPurchasing = true
        do {
            try await subscriptionService.purchase(plan: plan)
            showSuccessSheet = true
            toastMessage = "Welcome to PocketDo Premium! 🎉"
        } catch {
            toastMessage = "Purchase failed. Please try again."
        }
        isPurchasing = false
    }

    func restore() async {
        isRestoring = true
        do {
            try await subscriptionService.restorePurchases()
            toastMessage = subscriptionService.isPremium
                ? "Purchases restored ✓"
                : "No previous purchases found."
        } catch {
            toastMessage = "Restore failed. Please try again."
        }
        isRestoring = false
    }

    // MARK: - Features list (for non-premium upsell cards)

    let premiumFeatures: [(icon: String, title: String, description: String)] = [
        ("icloud.and.arrow.up.fill",  "Cloud Backup",         "Your tasks are safe and synced across all devices."),
        ("infinity",                   "Unlimited Tasks",      "Never hit a limit — add as many tasks as you need."),
        ("chart.pie.fill",             "Advanced Analytics",  "Insights on your productivity patterns over time."),
        ("bolt.shield.fill",           "Priority Support",    "Get help faster with dedicated customer support.")
    ]
}
