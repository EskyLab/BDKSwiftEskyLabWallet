//
//  BDKSwiftExampleWalletSendViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest

@testable import CypherPunkCulture

@MainActor
final class BDKSwiftExampleWalletSendViewModelTests: XCTestCase {

    // Test for AmountViewModel
    func testAmountViewModel() async {
        // Set up viewModel with mock client
        let viewModel = AmountViewModel(bdkClient: .mock)

        // Perform getBalance and wait for completion
        viewModel.getBalance()
        
        // Assert that the balance is greater than 0
        if let balance = viewModel.balanceTotal {
            XCTAssertGreaterThan(balance, UInt64(0), "Balance should be greater than 0")
        } else {
            XCTFail("Balance should not be nil")
        }
    }

    // Test for FeeViewModel
    func testFeeViewModel() async {
        // Set up viewModel with mock clients
        let viewModel = FeeViewModel(feeClient: .mock, bdkClient: .mock)

        // Perform getFees and wait for completion
        await viewModel.getFees()
        
        // Assert that the recommended fastest fee is as expected
        if let fees = viewModel.recommendedFees {
            XCTAssertEqual(fees.fastestFee, 10, "Fastest fee should be 10")
        } else {
            XCTFail("Recommended fees should not be nil")
       }
    }

    // Test for BuildTransactionViewModel
    func testBuildTransactionViewModel() async {
        // Set up viewModel with mock client
        let viewModel = BuildTransactionViewModel(bdkClient: .mock)

        let amount = "100000"
        let address = "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt"
        let fee: Float = 17.0

        // Perform buildTransaction and wait for completion
        viewModel.buildTransaction(
            address: address,
            amount: UInt64(Int64(amount) ?? 0),
            feeRate: fee
        )
        
        // Assert that the transaction fee is as expected
        if let txBuilderResult = viewModel.txBuilderResult {
            XCTAssertEqual(txBuilderResult.transactionDetails.fee, 2820, "Transaction fee should be 2820")
        } else {
            XCTFail("Transaction builder result should not be nil")
        }
    }
}
