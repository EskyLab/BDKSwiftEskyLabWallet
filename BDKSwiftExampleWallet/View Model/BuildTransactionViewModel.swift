//
//  BuildTransactionViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/23/23.
//

import BitcoinDevKit
import Foundation
import Combine

@MainActor
class BuildTransactionViewModel: ObservableObject {
    let bdkClient: BDKClient

    @Published var txBuilderResult: TxBuilderResult?
    @Published var buildTransactionViewError: BdkError?
    @Published var showingBuildTransactionViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) {
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.txBuilderResult = txBuilderResult
        } catch let error as WalletError {
            self.buildTransactionViewError = .Generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as BdkError {
            self.buildTransactionViewError = .Generic(message: error.description)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .Generic(message: "Error Building Transaction")
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func send(address: String, amount: UInt64, feeRate: Float?) {
        do {
            try bdkClient.send(address, amount, feeRate)
            NotificationCenter.default.post(
                name: Notification.Name("TransactionSent"),
                object: nil
            )
        } catch let error as WalletError {
            self.buildTransactionViewError = .Generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as BdkError {
            self.buildTransactionViewError = .Generic(message: error.description)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .Generic(message: "Error Sending Transaction")
            self.showingBuildTransactionViewErrorAlert = true
        }
    }
}
