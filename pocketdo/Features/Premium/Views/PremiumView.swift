// MARK: - File: Features/Premium/Views/PremiumView.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var vm = PremiumViewModel(subscriptionService: SubscriptionService())
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                // Background gradient
                VStack {
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B").opacity(0.12), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .frame(height: 300)
                    .ignoresSafeArea()
                    Spacer()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.xl) {
                        headerSection
                        featuresSection
                        pricingSection
                        ctaSection
                        restoreButton
                    }
                    .screenPadding()
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxxl)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.appOnSurfaceMuted)
                    }
                }
            }
            .sheet(isPresented: $vm.showSuccessSheet) {
                successSheet
            }
            .toast(message: $vm.toastMessage)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#F59E0B").opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.white)
            }
            .appShadow(.float)

            Text("Go Premium")
                .font(AppTypography.headlineLg)
                .foregroundStyle(Color.appOnSurface)

            Text("Unlock the full PocketDo experience with unlimited\ntasks, cloud sync, and advanced analytics.")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(vm.premiumFeatures, id: \.title) { feature in
                featureRow(icon: feature.icon, title: feature.title, description: feature.description)
            }
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color(hex: "#F59E0B").opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.titleSm)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appOnSurface)
                Text(description)
                    .font(AppTypography.bodySm)
                    .foregroundStyle(Color.appOnSurfaceVariant)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.appSecondary)
                .font(.system(size: 18))
        }
    }

    // MARK: - Pricing

    private var pricingSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Choose Your Plan")

            ForEach(vm.plans) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { vm.selectedPlan = plan }
        } label: {
            HStack(spacing: AppSpacing.md) {
                // Radio
                Circle()
                    .strokeBorder(
                        vm.selectedPlan?.id == plan.id ? Color.appPrimary : Color.appOutlineVariant,
                        lineWidth: 2
                    )
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 12, height: 12)
                            .opacity(vm.selectedPlan?.id == plan.id ? 1 : 0)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(plan.name)
                            .font(AppTypography.titleMd)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appOnSurface)
                        if plan.isRecommended {
                            Text("BEST VALUE")
                                .font(AppTypography.labelSm)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appOnPrimary)
                                .padding(.horizontal, AppSpacing.xxs + 2)
                                .padding(.vertical, 2)
                                .background(AppGradients.primaryCTA)
                                .clipShape(Capsule())
                        }
                    }
                    if let savings = plan.savings {
                        Text(savings)
                            .font(AppTypography.labelSm)
                            .foregroundStyle(Color.appSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(AppTypography.headlineSm)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appOnSurface)
                    Text("/ \(plan.period)")
                        .font(AppTypography.labelSm)
                        .foregroundStyle(Color.appOnSurfaceMuted)
                }
            }
            .padding(AppSpacing.md)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .strokeBorder(
                        vm.selectedPlan?.id == plan.id ? Color.appPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
            .appShadow(vm.selectedPlan?.id == plan.id ? .float : .card)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: vm.selectedPlan?.id)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        PrimaryButton(
            "Upgrade Now · \(vm.selectedPlan?.price ?? "") / \(vm.selectedPlan?.period ?? "")",
            icon: "crown.fill",
            isLoading: vm.isPurchasing
        ) {
            Task { await vm.purchase() }
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await vm.restore() }
        } label: {
            Text(vm.isRestoring ? "Restoring…" : "Restore Purchases")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appPrimary)
        }
    }

    // MARK: - Success Sheet

    private var successSheet: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(AppGradients.primaryCTA).frame(width: 100, height: 100)
                Image(systemName: "crown.fill").font(.system(size: 44)).foregroundStyle(Color.white)
            }
            .appShadow(.float)
            Text("Welcome to Premium! 🎉")
                .font(AppTypography.headlineMd)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.center)
            Text("You now have access to all premium features including cloud sync, unlimited tasks, and advanced analytics.")
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton("Start Using Premium") { vm.showSuccessSheet = false; dismiss() }
                .screenPadding()
        }
        .screenPadding()
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    PremiumView()
        .environmentObject(DependencyContainer())
}
