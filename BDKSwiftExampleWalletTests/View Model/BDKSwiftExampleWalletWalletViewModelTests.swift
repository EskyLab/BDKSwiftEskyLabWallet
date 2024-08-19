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

        // Set up viewModel with mock dependencies
        let viewModel = WalletViewModel(priceClient: .mock, bdkClient: .mock)
        
        // Initially, the wallet sync state should be 'notStarted'
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)

        // Simulate successful sync() call
        await viewModel.sync()
        // Assert that the wallet sync state is now 'synced'
        XCTAssertEqual(viewModel.walletSyncState, .synced)

        // Simulate successful getBalance() call
        viewModel.getBalance()
        // Assert that the balance is greater than 0
        XCTAssertGreaterThan(viewModel.balanceTotal, UInt64(0))

        // Simulate successful getTransactions() call
        viewModel.getTransactions()
        // Assert that there are more than 1 transaction in the details
        XCTAssertGreaterThan(viewModel.transactionDetails.count, 1)

        // Simulate successful getPrices() call
        await viewModel.getPrices()
        // Assert that the prices are updated (You may want to add an assertion here to verify the price data)
        
        // If needed, you can further assert or print values for debugging
        // Example:
        // print("Balance: \(viewModel.balanceTotal)")
        // print("Transactions: \(viewModel.transactionDetails)")
        // print("Prices: \(viewModel.prices)")  // Assuming there's a prices property in viewModel
    }
}
