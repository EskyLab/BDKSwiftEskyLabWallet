//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    let bdkClient: BDKClient
    let keyClient: KeyClient // Dependency injection for KeyClient

    @AppStorage("isOnboarding") var isOnboarding: Bool?

    @Published var networkColor = Color.gray
    @Published var onboardingViewError: BdkError?
    @Published var words: String = ""
    @Published var selectedNetwork: Network = .testnet {
        didSet {
            saveNetworkSelection()
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            saveEsploraURL()
        }
    }
    @Published var showingOnboardingViewErrorAlert: Bool = false
    @Published var isSyncing: Bool = false

    private let networkURLs: [Network: [String]] = [
        .bitcoin: Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues,
        .testnet: Constants.Config.EsploraServerURLNetwork.Testnet.allValues,
        .regtest: Constants.Config.EsploraServerURLNetwork.Regtest.allValues,
        .signet: Constants.Config.EsploraServerURLNetwork.Signet.allValues
    ]

    private let networkColors: [Network: Color] = [
        .bitcoin: Constants.BitcoinNetworkColor.bitcoin.color,
        .testnet: Constants.BitcoinNetworkColor.testnet.color,
        .signet: Constants.BitcoinNetworkColor.signet.color,
        .regtest: Constants.BitcoinNetworkColor.regtest.color
    ]

    var availableURLs: [String] {
        networkURLs[selectedNetwork] ?? ["default_url"]
    }

    var buttonColor: Color {
        networkColors[selectedNetwork] ?? .gray
    }

    init(bdkClient: BDKClient = .live, keyClient: KeyClient = .live) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        loadInitialSettings()
    }

    private func loadInitialSettings() {
        do {
            self.selectedNetwork = try keyClient.getNetwork().flatMap { Network(stringValue: $0) } ?? .testnet
            self.selectedURL = try keyClient.getEsploraURL() ?? availableURLs.first ?? ""
        } catch {
            setError(.Esplora(message: "Error Selecting Esplora"))
        }
    }

    private func saveNetworkSelection() {
        do {
            let networkString = selectedNetwork.description
            try keyClient.saveNetwork(networkString)
            selectedURL = availableURLs.first ?? ""
            try keyClient.saveEsploraURL(selectedURL)
        } catch {
            setError(.InvalidNetwork(message: "Error Selecting Network"))
        }
    }

    private func saveEsploraURL() {
        do {
            guard !selectedURL.isEmpty else {
                setError(.Esplora(message: "Invalid Esplora URL"))
                return
            }
            try keyClient.saveEsploraURL(selectedURL)
        } catch {
            setError(.Esplora(message: "Error Selecting Esplora"))
        }
    }

    func createWallet() {
        do {
            try bdkClient.createWallet(words)
            isOnboarding = false
            startBackgroundSync()
        } catch {
            setError(.Generic(message: "Error Creating Wallet"))
        }
    }

    private func startBackgroundSync() {
        isSyncing = true
        DispatchQueue.global(qos: .background).async {
            do {
                try self.syncWithServer()
            } catch {
                DispatchQueue.main.async {
                    self.setError(.Generic(message: "Error During Synchronization"))
                }
            }
            DispatchQueue.main.async {
                self.isSyncing = false
            }
        }
    }

    private func syncWithServer() throws {
        // Simulate network delay
        sleep(2)
        // Add your synchronization logic here
    }

    private func setError(_ error: BdkError) {
        DispatchQueue.main.async {
            self.onboardingViewError = error
        }
    }
}
