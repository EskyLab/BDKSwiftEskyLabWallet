//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Combine

class WalletViewModel: ObservableObject {
    let priceClient: PriceClient
    let bdkClient: BDKClient

    @Published var balanceTotal: UInt64 = 0
    @Published var walletSyncState: WalletSyncState = .notStarted
    @Published var transactionDetails: [TransactionDetails] = []
    @Published var price: Double = 0.00
    @Published var walletViewError: BdkError?
    @Published var showingWalletViewErrorAlert = false
    @Published var isSyncing: Bool = false
    @Published var isConfirmed: Bool = false
    @Published var activityText: String = "Syncing Wallet..."
    @Published var isRefreshing: Bool = false

    var satsPrice: String {
        let usdValue = Double(balanceTotal).valueInUSD(price: price)
        return usdValue
    }

    init(
        priceClient: PriceClient = .live,
        bdkClient: BDKClient = .live
    ) {
        self.priceClient = priceClient
        self.bdkClient = bdkClient
    }

    // Fetch the current price
    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            DispatchQueue.main.async {
                self.price = price.usd
            }
        } catch {
            self.handleError(error, message: "Error Getting Prices")
        }
    }

    // Fetch the balance from the wallet
    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            DispatchQueue.main.async {
                self.balanceTotal = balance.total
            }
        } catch {
            self.handleError(error, message: "Error Getting Balance")
        }
    }

    // Fetch the transactions from the wallet
    func getTransactions() {
        do {
            let transactionDetails = try bdkClient.getTransactions()
            DispatchQueue.main.async {
                self.transactionDetails = transactionDetails
            }
        } catch {
            self.handleError(error, message: "Error Getting Transactions")
        }
    }

    // Sync the wallet with the network
    func sync() async {
        updateSyncState(isSyncing: true, text: "Syncing Wallet...", state: .syncing)

        do {
            try await bdkClient.sync()
            updateSyncState(isSyncing: false, text: "Wallet Synced", state: .synced, isConfirmed: true)
        } catch {
            handleSyncError(error)
        }
    }

    // MARK: - Private Helpers

    private func updateSyncState(isSyncing: Bool, text: String, state: WalletSyncState, isConfirmed: Bool = false) {
        DispatchQueue.main.async {
            self.isSyncing = isSyncing
            self.activityText = text
            self.walletSyncState = state
            self.isConfirmed = isConfirmed
        }
    }

    private func handleError(_ error: Error, message: String) {
        DispatchQueue.main.async {
            self.walletViewError = .Generic(message: message)
            self.showingWalletViewErrorAlert = true
        }
    }

    private func handleSyncError(_ error: Error) {
        DispatchQueue.main.async {
            self.walletSyncState = .error(error)
            self.activityText = "Sync Failed"
            self.walletViewError = .Generic(message: "Error during sync")
            self.showingWalletViewErrorAlert = true
            self.isSyncing = false
        }
    }
}
