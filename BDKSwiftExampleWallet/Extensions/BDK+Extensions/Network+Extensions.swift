//
//  Network+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

extension Network {
    // Computed property to return a string description of the network
    var description: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .testnet: return "testnet"
        case .signet: return "signet"
        case .regtest: return "regtest"
        }
    }

    // Failable initializer to create a Network enum from a string
    init?(stringValue: String) {
        switch stringValue {
        case "bitcoin": self = .bitcoin
        case "testnet": self = .testnet
        case "signet": self = .signet
        case "regtest": self = .regtest
        default: return nil
        }
    }
}

#if DEBUG
    // Mock network for debugging purposes
    let mockKeyClientNetwork = Network.regtest
#endif
