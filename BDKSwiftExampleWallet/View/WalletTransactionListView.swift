//
//  WalletTransactionListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct WalletTransactionListView: View {
    let transactionDetails: [TransactionDetails]
    let walletSyncState: WalletSyncState
    @State private var showAllTransactions = false
    
    var body: some View {
        List {
            if transactionDetails.isEmpty && walletSyncState == .syncing {
                // Display loading state
                loadingStateView
            } else if transactionDetails.isEmpty {
                // No transactions
                Text("No Transactions")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                // Show last 10 transactions
                ForEach(
                    Array(transactionDetails.prefix(10)).sorted(
                        by: {
                            $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?.timestamp ?? $1.received
                        }
                    ),
                    id: \.txid
                ) { transaction in
                    transactionRow(for: transaction)
                }
                // Button to show all transactions
                if transactionDetails.count > 10 {
                    Button("Show All Transactions") {
                        showAllTransactions = true
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $showAllTransactions) {
            FullTransactionHistoryView(transactionDetails: transactionDetails)
        }
    }
    
    private var loadingStateView: some View {
        HStack(spacing: 15) {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.gray.opacity(0.5))
            VStack(alignment: .leading, spacing: 5) {
                Text("Loading...")
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundColor(.primary)
                Text("Syncing...")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
            Text("...")
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
        }
        .padding(.vertical, 15.0)
        .padding(.vertical, 5.0)
        .minimumScaleFactor(0.5)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    private func transactionRow(for transaction: TransactionDetails) -> some View {
        NavigationLink(
            destination: TransactionDetailsView(
                viewModel: .init(),
                transaction: transaction,
                amount: transaction.sent > 0
                ? transaction.sent - transaction.received
                : transaction.received - transaction.sent
            )
        ) {
            HStack(spacing: 15) {
                // Display appropriate arrow based on the transaction type
                Image(systemName: transaction.sent > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        transaction.sent > 0 ? Color.red : Color.green,  // Red for sent, Green for received
                        Color.gray.opacity(0.05)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(transaction.txid)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .fontDesign(.monospaced)
                        .fontWeight(.semibold)
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    // Display confirmation time or "Unconfirmed" in red
                    Text(
                        transaction.confirmationTime?.timestamp.toDate().formatted(.dateTime.day().month().hour().minute())
                        ?? "Unconfirmed"
                    )
                    .foregroundColor(transaction.confirmationTime == nil ? .red : .secondary)
                    .font(.subheadline)
                }
                
                Spacer()
                
                Text(
                    "\(transaction.sent > 0 ? transaction.sent - transaction.received : transaction.received - transaction.sent) sats"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
            }
            .padding(.vertical, 15.0)
            .padding(.vertical, 5.0)
            .minimumScaleFactor(0.5)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
    }
}

#if DEBUG
#Preview {
    WalletTransactionListView(
        transactionDetails: mockTransactionDetails,
        walletSyncState: .synced
    )
}

#Preview {
    WalletTransactionListView(
        transactionDetails: mockTransactionDetails,
        walletSyncState: .synced
    )
    .environment(\.sizeCategory, .accessibilityLarge)
}
#endif
