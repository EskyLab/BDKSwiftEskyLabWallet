//
//  TabHomeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@MainActor
class TabHomeViewModel: ObservableObject {
    let bdkClient: BDKClient

    @Published var tabViewError: BdkError?
    @Published var showingTabViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch let error as WalletError {
            handleError(.Generic(message: error.localizedDescription))
        } catch let error as BdkError {
            handleError(error)
        } catch {
            handleError(.Generic(message: "Unknown error occurred"))
        }
    }

    private func handleError(_ error: BdkError) {
        self.tabViewError = error
        self.showingTabViewErrorAlert = true
    }
}
