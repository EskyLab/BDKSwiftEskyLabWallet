//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Combine
import Promises

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

    // Fetch the current price using Promises
    func getPrices() -> Promise<Void> {
        return Promise { fulfill, reject in
            Task {
                do {
                    let price = try await self.priceClient.fetchPrice()  // Explicit `self`
                    DispatchQueue.main.async {
                        self.price = price.usd
                        fulfill(())
                    }
                } catch {
                    reject(error)
                    self.handleError(error, message: "Error Getting Prices")
                }
            }
        }
    }

    // Fetch the balance from the wallet using Promises
    func getBalance() -> Promise<Void> {
        return Promise { fulfill, reject in
            do {
                let balance = try self.bdkClient.getBalance()  // Explicit `self`
                DispatchQueue.main.async {
                    self.balanceTotal = balance.total
                    fulfill(())
                }
            } catch {
                reject(error)
                self.handleError(error, message: "Error Getting Balance")
            }
        }
    }

    // Fetch the transactions from the wallet using Promises
    func getTransactions() -> Promise<Void> {
        return Promise { fulfill, reject in
            do {
                let transactionDetails = try self.bdkClient.getTransactions()  // Explicit `self`
                DispatchQueue.main.async {
                    self.transactionDetails = transactionDetails
                    fulfill(())
                }
            } catch {
                reject(error)
                self.handleError(error, message: "Error Getting Transactions")
            }
        }
    }

    // Sync the wallet with the network using Promises
    func sync() -> Promise<Void> {
        updateSyncState(isSyncing: true, text: "Syncing Wallet...", state: .syncing)

        return Promise { fulfill, reject in
            Task {
                do {
                    try await self.bdkClient.sync()  // Explicit `self`
                    DispatchQueue.main.async {
                        self.updateSyncState(isSyncing: false, text: "Wallet Synced", state: .synced, isConfirmed: true)
                        fulfill(())
                    }
                } catch {
                    reject(error)
                    self.handleSyncError(error)
                }
            }
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
            if let bdkError = error as? BdkError {
                self.walletViewError = bdkError
            } else {
                self.walletViewError = .Generic(message: message)
            }
            self.showingWalletViewErrorAlert = true
        }
    }

    private func handleSyncError(_ error: Error) {
        DispatchQueue.main.async {
            if let bdkError = error as? BdkError {
                self.walletSyncState = .error(bdkError)
            } else {
                self.walletSyncState = .error(BdkError.Generic(message: "Sync Failed"))
            }
            self.activityText = "Sync Failed"
            self.walletViewError = .Generic(message: "Error during sync")
            self.showingWalletViewErrorAlert = true
            self.isSyncing = false
        }
    }
}
