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

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        self.getNetwork()
        self.getEsploraUrl()
    }

    // Fetch the network from the key client
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

    // Fetch the Esplora URL based on the network
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
                self.transactionDetailsError = BdkError.Generic(message: "Could not get esplora")
                self.showingTransactionDetailsViewErrorAlert = true
            }
        }
    }
}
