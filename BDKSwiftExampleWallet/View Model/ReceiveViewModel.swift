//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Observation

@Observable
class ReceiveViewModel {
    let bdkClient: BDKClient

    var address: String = ""
    var receiveViewError: BdkError?
    var showingReceiveViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    // Updated to async
    func getAddress() async {
        do {
            // Wrap the synchronous call in a Task to support async/await
            self.address = try await withCheckedThrowingContinuation { continuation in
                do {
                    let address = try bdkClient.getAddress()
                    continuation.resume(returning: address)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } catch let error as WalletError {
            self.receiveViewError = .Generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        } catch let error as BdkError {
            self.receiveViewError = .Generic(message: error.description)
            self.showingReceiveViewErrorAlert = true
        } catch {
            self.receiveViewError = .Generic(message: "Error Getting Address")
            self.showingReceiveViewErrorAlert = true
        }
    }
}
