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

    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            DispatchQueue.main.async {
                self.price = price.usd
            }
        } catch {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: "Error Getting Prices")
                self.showingWalletViewErrorAlert = true
            }
        }
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            DispatchQueue.main.async {
                self.balanceTotal = balance.total
            }
        } catch let error as WalletError {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: error.localizedDescription)
                self.showingWalletViewErrorAlert = true
            }
        } catch let error as BdkError {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: error.description)
                self.showingWalletViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: "Error Getting Balance")
                self.showingWalletViewErrorAlert = true
            }
        }
    }

    func getTransactions() {
        do {
            let transactionDetails = try bdkClient.getTransactions()
            DispatchQueue.main.async {
                self.transactionDetails = transactionDetails
            }
        } catch let error as WalletError {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: error.localizedDescription)
                self.showingWalletViewErrorAlert = true
            }
        } catch let error as BdkError {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: error.description)
                self.showingWalletViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.walletViewError = .Generic(message: "Error Getting Transactions")
                self.showingWalletViewErrorAlert = true
            }
        }
    }

    func sync() async {
        DispatchQueue.main.async {
            self.isSyncing = true
            self.activityText = "Syncing Wallet..."
            self.walletSyncState = .syncing
        }
        do {
            try await bdkClient.sync()
            DispatchQueue.main.async {
                self.walletSyncState = .synced
                self.isConfirmed = true
                self.activityText = "Wallet Synced"
                self.isSyncing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.walletSyncState = .error(error)
                self.activityText = "Sync Failed"
                self.showingWalletViewErrorAlert = true
                self.isSyncing = false
            }
        }
    }
}
