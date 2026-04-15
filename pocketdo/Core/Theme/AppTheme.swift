// MARK: - File: Core/Theme/AppTheme.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI
import Combine

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil // nil = follow system

    static let shared = ThemeManager()

    func setMode(_ mode: AppColorMode) {
        switch mode {
        case .light:  colorScheme = .light
        case .dark:   colorScheme = .dark
        case .system: colorScheme = nil
        }
    }
}

enum AppColorMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

// MARK: - App Colors

extension Color {
    // Primary — Deep authoritative Indigo
    static let appPrimary         = Color(hex: "#3525CD")
    static let appPrimaryLight    = Color(hex: "#6B5FF5")
    static let appPrimaryContainer = Color(hex: "#E8E6FF")

    // Secondary — Lush success-oriented Green
    static let appSecondary            = Color(hex: "#006E2F")
    static let appSecondaryLight       = Color(hex: "#4ADE80")
    static let appSecondaryContainer   = Color(hex: "#DCFCE7")

    // Error / Warning
    static let appError   = Color(hex: "#EF4444")
    static let appWarning = Color(hex: "#F59E0B")
    static let appSuccess = Color(hex: "#22C55E")

    // Priority
    static let priorityLow    = Color(hex: "#22C55E")
    static let priorityMedium = Color(hex: "#F59E0B")
    static let priorityHigh   = Color(hex: "#EF4444")

    // Adaptive semantic surfaces — Light/Dark auto-switching
    static let appBackground = Color(
        light: Color(hex: "#F3F4F5"),
        dark:  Color(hex: "#0B1120")
    )
    static let appSurface = Color(
        light: Color(hex: "#FFFFFF"),
        dark:  Color(hex: "#1A2236")
    )
    static let appSurfaceLow = Color(
        light: Color(hex: "#F3F4F5"),
        dark:  Color(hex: "#111827")
    )
    static let appSurfaceVariant = Color(
        light: Color(hex: "#E8E9EC"),
        dark:  Color(hex: "#243049")
    )
    static let appSurfaceDim = Color(
        light: Color(hex: "#E4E5E8"),
        dark:  Color(hex: "#0D1526")
    )

    // Text
    static let appOnSurface = Color(
        light: Color(hex: "#111827"),
        dark:  Color(hex: "#F1F5F9")
    )
    static let appOnSurfaceVariant = Color(
        light: Color(hex: "#5C5C7A"),
        dark:  Color(hex: "#94A3B8")
    )
    static let appOnSurfaceMuted = Color(
        light: Color(hex: "#9CA3AF"),
        dark:  Color(hex: "#64748B")
    )

    // Outline (ghost border — felt, not seen)
    static let appOutlineVariant = Color(
        light: Color(hex: "#E5E7EB").opacity(0.7),
        dark:  Color(hex: "#334155").opacity(0.7)
    )

    // On primary/secondary
    static let appOnPrimary   = Color.white
    static let appOnSecondary = Color.white

    // Shadow tint (never use pure black)
    static let appShadowTint = Color(
        light: Color(hex: "#1A1A2E").opacity(0.06),
        dark:  Color(hex: "#000000").opacity(0.35)
    )
}

// MARK: - Color Hex Init

extension Color {
    // Adaptive light/dark color helper
    init(light: Color, dark: Color) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - App Typography

enum AppTypography {
    // Headlines — Manrope Bold (falls back to rounded system font)
    static let displaySm  = font("Manrope-Bold",    size: 36, fallbackWeight: .black,    design: .rounded)
    static let headlineLg = font("Manrope-Bold",    size: 32, fallbackWeight: .bold,     design: .rounded)
    static let headlineMd = font("Manrope-SemiBold", size: 24, fallbackWeight: .semibold, design: .rounded)
    static let headlineSm = font("Manrope-SemiBold", size: 20, fallbackWeight: .semibold, design: .rounded)

    // Titles / Body — Inter (falls back to default system font)
    static let titleLg  = font("Inter-SemiBold", size: 18, fallbackWeight: .semibold)
    static let titleMd  = font("Inter-Medium",   size: 16, fallbackWeight: .medium)
    static let titleSm  = font("Inter-Medium",   size: 14, fallbackWeight: .medium)
    static let bodyMd   = font("Inter-Regular",  size: 14, fallbackWeight: .regular)
    static let bodySm   = font("Inter-Regular",  size: 13, fallbackWeight: .regular)
    static let labelMd  = font("Inter-Medium",   size: 12, fallbackWeight: .medium)
    static let labelSm  = font("Inter-Regular",  size: 11, fallbackWeight: .regular)

    private static func font(
        _ name: String,
        size: CGFloat,
        fallbackWeight: Font.Weight,
        design: Font.Design = .default
    ) -> Font {
        // Try custom font; fall back gracefully if not embedded yet
        let descriptor = UIFontDescriptor(name: name, size: size)
        if UIFont(descriptor: descriptor, size: size).fontName == name {
            return Font.custom(name, size: size)
        }
        return Font.system(size: size, weight: fallbackWeight, design: design)
    }
}

// MARK: - App Spacing (8pt grid)

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24   // standard screen horizontal padding
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - App Corner Radius

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16    // nested elements
    static let xl: CGFloat = 24    // main task cards
    static let xxl: CGFloat = 32
    static let pill: CGFloat = 100
}

// MARK: - App Shadow

enum ShadowLevel { case card, float, sheet }

struct AppShadowModifier: ViewModifier {
    let level: ShadowLevel
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        switch level {
        case .card:
            content
                .shadow(
                    color: shadowColor(opacity: colorScheme == .dark ? 0.35 : 0.06),
                    radius: 16, x: 0, y: 6
                )
        case .float:
            content
                .shadow(
                    color: shadowColor(opacity: colorScheme == .dark ? 0.45 : 0.10),
                    radius: 24, x: 0, y: 8
                )
        case .sheet:
            content
                .shadow(
                    color: shadowColor(opacity: colorScheme == .dark ? 0.55 : 0.14),
                    radius: 40, x: 0, y: 16
                )
        }
    }

    private func shadowColor(opacity: Double) -> Color {
        colorScheme == .dark
            ? Color.black.opacity(opacity)
            : Color(hex: "#1A1A2E").opacity(opacity)
    }
}

extension View {
    func appShadow(_ level: ShadowLevel = .card) -> some View {
        modifier(AppShadowModifier(level: level))
    }
}

// MARK: - App Gradients

enum AppGradients {
    /// Primary CTA — Indigo → lighter Indigo (buttons, FAB)
    static let primaryCTA = LinearGradient(
        colors: [Color(hex: "#3525CD"), Color(hex: "#6B5FF5")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Hero background for auth screen
    static let heroBackground = LinearGradient(
        colors: [Color(hex: "#3525CD").opacity(0.12), Color(hex: "#F3F4F5").opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Hero background for auth screen dark mode
    static let heroBackgroundDark = LinearGradient(
        colors: [Color(hex: "#3525CD").opacity(0.20), Color(hex: "#0B1120").opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass surface for bottom nav
    static let glassSurface = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.01)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Success accent
    static let successAccent = LinearGradient(
        colors: [Color(hex: "#006E2F"), Color(hex: "#22C55E")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Pie chart segment colors
    static let chartCompleted = Color(hex: "#3525CD")
    static let chartPending   = Color(hex: "#F59E0B")
    static let chartOverdue   = Color(hex: "#EF4444")
}
