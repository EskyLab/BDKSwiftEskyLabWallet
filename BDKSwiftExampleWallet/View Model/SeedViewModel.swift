//
//  SeedViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@MainActor
class SeedViewModel: ObservableObject {
    @Published var seed: BackupInfo = BackupInfo(mnemonic: "", descriptor: "", changeDescriptor: "")
    @Published var seedViewError: BdkError?
    @Published var showingSeedViewErrorAlert = false

    private let bdkClient: BDKClient

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getSeed() {
        do {
            let seed = try bdkClient.getBackupInfo()
            self.seed = seed
        } catch {
            self.seedViewError = BdkError.Generic(message: "Could not show seed")
            self.showingSeedViewErrorAlert = true
        }
    }
}
