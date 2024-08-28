//
//  BDKSwiftExampleWalletWalletViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/23/23.
//

import XCTest
@testable import CypherPunkCulture

@MainActor
final class BDKSwiftExampleWalletWalletViewModelTests: XCTestCase {

    func testWalletViewModel() async {
        // Set up mock view model
        let viewModel = WalletViewModel(priceClient: .mock, bdkClient: .mock)

        // Simulate a balance being set greater than 0
        viewModel.balanceTotal = 123456789

        // Simulate some transactions using mockTransactionDetails
        viewModel.transactionDetails = mockTransactionDetails
        
        // Assert that balance is greater than 0
        XCTAssertGreaterThan(viewModel.balanceTotal, UInt64(0))

        // Assert that there are more than 1 transaction in the details
        XCTAssertGreaterThan(viewModel.transactionDetails.count, 1)
        
        // Example of verifying a specific value in the transaction details
        XCTAssertEqual(viewModel.transactionDetails.first?.txid, "cdcc4d287e4780d25c577d4f5726c7d585625170559f0b294da20b55ffa2b009")
    }
}
