// MARK: - File: App/AppRouter.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                AuthView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: authService.isAuthenticated)
    }
}
