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

        // Set biometric preference to true on first launch
        if !hasLaunchedBefore {
            isBiometricEnabled = false // Default to false on first launch
            hasLaunchedBefore = true
        }
    }

    func delete() {
        do {
            try bdkClient.deleteWallet()
            self.isOnboarding = true
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
                self.showingSettingsViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
                self.showingSettingsViewErrorAlert = true
            }
        }
    }

    func getNetwork() {
        do {
            self.network = try keyClient.getNetwork()
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get network")
                self.showingSettingsViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get network")
                self.showingSettingsViewErrorAlert = true
            }
        }
    }

    func getEsploraUrl() {
        do {
            self.esploraURL = try keyClient.getEsploraURL()
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get esplora")
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get esplora")
            }
        }
    }
}
