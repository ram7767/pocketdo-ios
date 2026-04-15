// MARK: - File: Core/Extensions/View+Extensions.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

// MARK: - Layout Helpers

extension View {
    /// Standard screen horizontal padding (24pt per design system)
    func screenPadding() -> some View {
        self.padding(.horizontal, AppSpacing.lg)
    }

    /// Card container style — xl radius, surface-lowest bg, card shadow
    func cardStyle(background: Color = .appSurface) -> some View {
        self
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .appShadow(.card)
    }

    /// Subtle nested card — lg radius, surfaceVariant bg
    func innerCardStyle() -> some View {
        self
            .background(Color.appSurfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    /// Full width button stretch
    func fillWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Shimmer / Skeleton

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width * 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Haptic Feedback

extension View {
    func onTapWithHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
            action()
        }
    }
}

// MARK: - Toast / Snackbar Support

extension View {
    func toast(message: Binding<String?>, duration: Double = 2.5) -> some View {
        self.overlay(alignment: .bottom) {
            if let msg = message.wrappedValue {
                Text(msg)
                    .font(AppTypography.bodyMd)
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(Color.appOnSurface)
                    .clipShape(Capsule())
                    .appShadow(.float)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(.spring()) { message.wrappedValue = nil }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4), value: message.wrappedValue)
    }
}
