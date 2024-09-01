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

    @AppStorage("isOnboarding") var isOnboarding: Bool?

    @Published var networkColor = Color.gray
    @Published var onboardingViewError: BdkError?
    @Published var words: String = ""
    @Published var selectedNetwork: Network = .testnet {
        didSet {
            DispatchQueue.main.async {
                do {
                    let networkString = self.selectedNetwork.description
                    try KeyClient.live.saveNetwork(networkString)
                    // Ensure selectedURL is a valid URL for the new network
                    self.selectedURL = self.availableURLs.first ?? ""
                    try KeyClient.live.saveEsploraURL(self.selectedURL)
                } catch {
                    self.onboardingViewError = .InvalidNetwork(message: "Error Selecting Network")
                }
            }
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            DispatchQueue.main.async {
                do {
                    try KeyClient.live.saveEsploraURL(self.selectedURL)
                } catch {
                    self.onboardingViewError = .Esplora(message: "Error Selecting Esplora")
                }
            }
        }
    }
    @Published var showingOnboardingViewErrorAlert: Bool = false
    @Published var isSyncing: Bool = false

    var availableURLs: [String] {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
        case .testnet:
            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
        case .regtest:
            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
        case .signet:
            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
        }
    }

    var buttonColor: Color {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.BitcoinNetworkColor.bitcoin.color
        case .testnet:
            return Constants.BitcoinNetworkColor.testnet.color
        case .signet:
            return Constants.BitcoinNetworkColor.signet.color
        case .regtest:
            return Constants.BitcoinNetworkColor.regtest.color
        }
    }

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
        DispatchQueue.main.async {
            do {
                if let networkString = try KeyClient.live.getNetwork() {
                    self.selectedNetwork = Network(stringValue: networkString) ?? .testnet
                } else {
                    self.selectedNetwork = .testnet
                }
                if let esploraURL = try KeyClient.live.getEsploraURL() {
                    self.selectedURL = esploraURL
                } else {
                    // Ensure selectedURL is set to a valid default
                    self.selectedURL = self.availableURLs.first ?? ""
                }
            } catch {
                self.onboardingViewError = .Esplora(message: "Error Selecting Esplora")
            }
        }
    }

    func createWallet() {
        DispatchQueue.main.async {
            do {
                try self.bdkClient.createWallet(self.words)
                self.isOnboarding = false
                // Start background synchronization after wallet creation
                self.startBackgroundSync()
            } catch {
                self.onboardingViewError = .Generic(message: "Error Creating Wallet")
            }
        }
    }

    private func startBackgroundSync() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.isSyncing = true
            }
            do {
                // Replace with actual synchronization logic
                try self.syncWithServer()
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .Generic(message: "Error During Synchronization")
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
}
