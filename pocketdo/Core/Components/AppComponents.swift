// MARK: - File: Core/Components/AppComponents.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView().tint(.white).scaleEffect(0.85)
                } else {
                    if let icon { Image(systemName: icon) }
                    Text(title).font(AppTypography.titleMd).fontWeight(.semibold)
                }
            }
            .foregroundStyle(Color.appOnPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppGradients.primaryCTA)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .appShadow(.card)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                if let icon { Image(systemName: icon) }
                Text(title).font(AppTypography.titleMd).fontWeight(.medium)
            }
            .foregroundStyle(Color.appPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appPrimaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ghost Button (Tertiary)

struct GhostButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if let icon { Image(systemName: icon).font(.system(size: 15)) }
                Text(title).font(AppTypography.titleSm).fontWeight(.medium)
            }
            .foregroundStyle(Color.appOnSurfaceVariant)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Text Field

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isFocused ? Color.appPrimary : Color.appOnSurfaceVariant)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .font(AppTypography.bodyMd)
                .foregroundStyle(Color.appOnSurface)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                if !text.isEmpty {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appOnSurfaceMuted)
                            .font(.system(size: 15))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 52)
            .background(Color.appSurfaceLow)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .strokeBorder(
                        isFocused ? Color.appPrimary.opacity(0.6) : Color.appOutlineVariant,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .focused($isFocused)

            if let error = errorMessage {
                Text(error)
                    .font(AppTypography.labelSm)
                    .foregroundStyle(Color.appError)
                    .padding(.leading, AppSpacing.xs)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

// MARK: - Card View

struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppSpacing.md
    var background: Color = .appSurface

    init(padding: CGFloat = AppSpacing.md, background: Color = .appSurface, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .appShadow(.card)
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let tag: Tag
    var isSelected: Bool = false
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: tag.colorHex))
                .frame(width: 6, height: 6)
            Text(tag.name)
                .font(AppTypography.labelMd)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color.appOnSurface : Color.appOnSurfaceVariant)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.appOnSurfaceVariant)
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs + 2)
        .background(
            isSelected
                ? Color.appSecondaryContainer
                : Color.appSurfaceVariant
        )
        .clipShape(Capsule())
    }
}

// MARK: - Priority Badge

struct PriorityBadge: View {
    let priority: Priority

    private var color: Color {
        switch priority {
        case .low:    return .priorityLow
        case .medium: return .priorityMedium
        case .high:   return .priorityHigh
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.icon)
                .font(.system(size: 9, weight: .bold))
            Text(priority.rawValue)
                .font(AppTypography.labelSm)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: TaskStatus

    private var color: Color {
        switch status {
        case .pending:   return .priorityMedium
        case .completed: return .appSecondary
        case .overdue:   return .appError
        }
    }

    private var icon: String {
        switch status {
        case .pending:   return "clock"
        case .completed: return "checkmark.circle.fill"
        case .overdue:   return "exclamationmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9))
            Text(status.rawValue).font(AppTypography.labelSm).fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 3)
        .background(color.opacity(0.10))
        .clipShape(Capsule())
    }
}

// MARK: - Sync Status Badge

struct SyncStatusBadge: View {
    let status: SyncStatus

    private var color: Color {
        switch status {
        case .synced:   return .appSecondary
        case .syncing:  return .appPrimary
        case .pending:  return .priorityMedium
        case .failed:   return .appError
        case .offline:  return .appOnSurfaceMuted
        }
    }

    private var icon: String {
        switch status {
        case .synced:   return "checkmark.icloud.fill"
        case .syncing:  return "arrow.triangle.2.circlepath.icloud.fill"
        case .pending:  return "icloud.fill"
        case .failed:   return "exclamationmark.icloud.fill"
        case .offline:  return "icloud.slash.fill"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 12))
            Text(status.rawValue).font(AppTypography.labelSm)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 3)
        .background(color.opacity(0.10))
        .clipShape(Capsule())
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appPrimaryContainer.opacity(0.6))
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.appPrimary)
            }

            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.headlineSm)
                    .foregroundStyle(Color.appOnSurface)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            if let actionTitle, let action {
                PrimaryButton(actionTitle, action: action)
                    .frame(width: 180)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Loading Skeleton

struct SkeletonRow: View {
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .fill(Color.appSurfaceVariant)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(Color.appSurfaceVariant)
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(Color.appSurfaceVariant)
                    .frame(width: 120, height: 11)
            }
        }
        .padding(AppSpacing.md)
        .shimmer()
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                }
                Spacer()
                if let trend {
                    Text(trend)
                        .font(AppTypography.labelSm)
                        .foregroundStyle(color)
                }
            }

            Text(value)
                .font(AppTypography.headlineMd)
                .fontWeight(.bold)
                .foregroundStyle(Color.appOnSurface)

            Text(title)
                .font(AppTypography.labelMd)
                .foregroundStyle(Color.appOnSurfaceVariant)
        }
        .padding(AppSpacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        .appShadow(.card)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(AppTypography.headlineSm)
                .fontWeight(.bold)
                .foregroundStyle(Color.appOnSurface)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.labelMd)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

// MARK: - FAB (Floating Action Button)

struct FABButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                Text("Add Task")
                    .font(AppTypography.titleSm)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color.appOnPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppGradients.primaryCTA)
            .clipShape(Capsule())
            .appShadow(.float)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (Tag chips wrapping)

struct FlowLayout: Layout {
    var spacing: CGFloat = AppSpacing.xs

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
