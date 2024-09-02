//
//  AmountViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/22/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@MainActor
class AmountViewModel: ObservableObject {
    let bdkClient: BDKClient

    @Published var balanceTotal: UInt64?
    @Published var balanceConfirmed: UInt64?
    @Published var amountViewError: BdkError?
    @Published var showingAmountViewErrorAlert = false
    @Published var exchangeRate: Double? // Store exchange rate

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getBalance() async {
        do {
            let balance = try await fetchBalance()
            self.balanceTotal = balance.total
            self.balanceConfirmed = balance.confirmed
        } catch let error as WalletError {
            self.amountViewError = .Generic(message: error.localizedDescription)
            self.showingAmountViewErrorAlert = true
        } catch let error as BdkError {
            self.amountViewError = .Generic(message: error.description)
            self.showingAmountViewErrorAlert = true
        } catch {
            self.amountViewError = .Generic(message: "Error Getting Balance")
            self.showingAmountViewErrorAlert = true
        }
    }

    private func fetchBalance() async throws -> Balance {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let balance = try bdkClient.getBalance()
                continuation.resume(returning: balance)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // Method to fetch exchange rate
    func fetchExchangeRate() async {
        // Simulating fetching the exchange rate (e.g., from an API)
        // Example: 1 BTC = 40,000 USD, so 1 sats = 0.0004 USD
        self.exchangeRate = 0.0004
    }

    // Calculate dollar amount
    func calculateDollarAmount(sats: UInt64) -> String {
        guard let exchangeRate = exchangeRate else { return "$0.00" }
        let dollars = Double(sats) * exchangeRate
        return String(format: "$%.2f", dollars)
    }
}

// Example usage of BdkError for demonstration
// Note: This should be placed inside a function or a view's body to avoid top-level execution errors

func printErrorExample() {
    let error: BdkError = .InsufficientFunds(message: "Not enough funds to complete the transaction")
    print(error.description) // Outputs: "Not enough funds to complete the transaction"
}
