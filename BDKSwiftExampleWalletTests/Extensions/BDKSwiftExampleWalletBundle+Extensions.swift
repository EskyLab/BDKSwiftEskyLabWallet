//
//  BDKSwiftExampleWalletBundle+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/22/23.
//

import XCTest
@testable import CypherPunkCulture

final class BDKSwiftExampleWalletBundle_Extensions: XCTestCase {

    func testDisplayName() {
        let displayName = Bundle.main.displayName

        // Check that the displayName is not empty
        XCTAssertFalse(displayName.isEmpty, "displayName should not be empty")

        // Retrieve the bundle name and identifier for validation
        let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let bundleIdentifier = Bundle.main.bundleIdentifier

        // Validate displayName against the expected value
        if let bundleName = bundleName {
            XCTAssertEqual(displayName, bundleName, "displayName should match the CFBundleName")
        } else if let bundleIdentifier = bundleIdentifier {
            XCTAssertEqual(displayName, bundleIdentifier, "displayName should match the bundleIdentifier")
        } else {
            XCTAssertEqual(displayName, "Unknown Bundle", "displayName should be 'Unknown Bundle' if both CFBundleName and bundleIdentifier are unavailable")
        }
    }
}
