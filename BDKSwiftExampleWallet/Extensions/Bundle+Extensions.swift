//
//  Bundle+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/22/23.
//

import Foundation

extension Bundle {
    var displayName: String {
        if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        }
        if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }
        return Bundle.main.bundleIdentifier ?? "Unknown Bundle"
    }
}
