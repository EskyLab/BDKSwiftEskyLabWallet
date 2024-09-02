//
//  TransactionDetailsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/15/24.
//

import BitcoinDevKit
import Foundation

class TransactionDetailsViewModel: ObservableObject {
    let bdkClient: BDKClient
    let keyClient: KeyClient

    @Published var network: String?
    @Published var esploraURL: String?
    @Published var transactionDetailsError: BdkError?
    @Published var showingTransactionDetailsViewErrorAlert = false

    @Published var confirmedTransactions: [TransactionDetails] = []
    @Published var unconfirmedTransactions: [TransactionDetails] = []

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        self.getNetwork()
        self.getEsploraUrl()
        self.fetchTransactions()
    }

    func getNetwork() {
        do {
            self.network = try keyClient.getNetwork()
        } catch {
            DispatchQueue.main.async {
                self.transactionDetailsError = BdkError.Generic(message: "Could not get network")
                self.showingTransactionDetailsViewErrorAlert = true
            }
        }
    }

    func getEsploraUrl() {
        do {
            let savedEsploraURL = try keyClient.getEsploraURL()
            if network == "Signet" {
                self.esploraURL = "https://mempool.space/signet"
            } else {
                self.esploraURL = savedEsploraURL
            }
        } catch {
            DispatchQueue.main.async {
                self.transactionDetailsError = BdkError.Generic(message: "Could not get esplora URL")
                self.showingTransactionDetailsViewErrorAlert = true
            }
        }
    }

    func fetchTransactions() {
        do {
            let transactions = try bdkClient.getTransactions()

            self.confirmedTransactions = transactions.filter { $0.confirmationTime != nil }
            self.unconfirmedTransactions = transactions.filter { $0.confirmationTime == nil }
        } catch {
            DispatchQueue.main.async {
                self.transactionDetailsError = BdkError.Generic(message: "Could not fetch transactions")
                self.showingTransactionDetailsViewErrorAlert = true
            }
        }
    }
}
