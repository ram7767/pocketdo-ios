// MARK: - File: Core/Utilities/AppError.swift
//  pocketdo
//
//  Created by Ratnakaram Rama Narasimha Raju on 15/04/26.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    // Auth
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case sessionExpired

    // Network
    case noInternet
    case serverError(code: Int)
    case timeout
    case unauthorized

    // Storage
    case saveFailed
    case fetchFailed
    case deleteFailed

    // Sync
    case syncFailed
    case conflictDetected

    // General
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:   return "Invalid email or password."
        case .emailAlreadyInUse:    return "An account with this email already exists."
        case .weakPassword:         return "Password must be at least 8 characters."
        case .userNotFound:         return "No account found with this email."
        case .sessionExpired:       return "Your session has expired. Please log in again."
        case .noInternet:           return "No internet connection. Check your network."
        case .serverError(let c):   return "Server error (\(c)). Please try again later."
        case .timeout:              return "Request timed out. Please try again."
        case .unauthorized:         return "You are not authorized to perform this action."
        case .saveFailed:           return "Failed to save. Please try again."
        case .fetchFailed:          return "Failed to load data. Please try again."
        case .deleteFailed:         return "Failed to delete item."
        case .syncFailed:           return "Sync failed. Your data is safe locally."
        case .conflictDetected:     return "A sync conflict was detected. Local version kept."
        case .unknown(let msg):     return msg
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noInternet:       return "Enable Wi-Fi or mobile data and try again."
        case .sessionExpired:   return "Return to the login screen."
        case .syncFailed:       return "Try syncing manually from Settings."
        default:                return nil
        }
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
