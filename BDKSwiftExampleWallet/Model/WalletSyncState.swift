//
//  WalletSyncState.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import Foundation

enum WalletSyncState: CustomStringConvertible, Equatable, Hashable {
    case error(Error)
    case notStarted
    case synced
    case syncing

    var description: String {
        switch self {
        case .error(let error):
            // Provide more detailed error information if needed
            return "Error Syncing: \(error.localizedDescription)"
        case .notStarted:
            return "Not Started"
        case .synced:
            return "Synced"
        case .syncing:
            return "Syncing"
        }
    }

    // Equatable implementation
    static func == (lhs: WalletSyncState, rhs: WalletSyncState) -> Bool {
        switch (lhs, rhs) {
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.notStarted, .notStarted):
            return true
        case (.synced, .synced):
            return true
        case (.syncing, .syncing):
            return true
        default:
            return false
        }
    }

    // Hashable implementation for better performance in collections that require hashing
    func hash(into hasher: inout Hasher) {
        switch self {
        case .error(let error):
            hasher.combine("error")
            hasher.combine(error.localizedDescription)
        case .notStarted:
            hasher.combine("notStarted")
        case .synced:
            hasher.combine("synced")
        case .syncing:
            hasher.combine("syncing")
        }
    }
}
