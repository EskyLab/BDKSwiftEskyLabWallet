//
//  SettingsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    let bdkClient: BDKClient
    let keyClient: KeyClient

    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("isBiometricEnabled") var isBiometricEnabled: Bool = false // Set default to false
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false // Track first launch

    @Published var settingsError: BdkError?
    @Published var showingSettingsViewErrorAlert = false
    @Published var network: String?
    @Published var esploraURL: String?

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient

        if !hasLaunchedBefore {
            isBiometricEnabled = false // Default to false on first launch
            hasLaunchedBefore = true
        }
    }

    func delete() {
        handleBDKError {
            try bdkClient.deleteWallet()
            self.isOnboarding = true
        }
    }

    func getNetwork() {
        handleBDKError {
            self.network = try keyClient.getNetwork()
        }
    }

    func getEsploraUrl() {
        handleBDKError {
            self.esploraURL = try keyClient.getEsploraURL()
        }
    }

    private func handleBDKError(_ action: () throws -> Void) {
        do {
            try action()
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Operation failed")
                self.showingSettingsViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Unknown error occurred")
                self.showingSettingsViewErrorAlert = true
            }
        }
    }
}
