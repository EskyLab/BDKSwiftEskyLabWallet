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
                loadingStateView
            } else if transactionDetails.isEmpty {
                Text("No Transactions")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(
                    Array(transactionDetails.prefix(10)).sorted(by: transactionSortCriteria),
                    id: \.txid
                ) { transaction in
                    transactionRow(for: transaction)
                }
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
        .paddingVertical()
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
                Image(systemName: transaction.sent > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        transaction.sent > 0 ? Color.red : Color.green,
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
                    
                    Text(transaction.confirmationTime?.timestamp.toDate().formatted(.dateTime.day().month().hour().minute()) ?? "Unconfirmed")
                        .foregroundColor(transaction.confirmationTime == nil ? .red : .secondary)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(transaction.sent > 0 ? transaction.sent - transaction.received : transaction.received - transaction.sent) sats")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .lineLimit(1)
            }
            .paddingVertical()
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
    }

    private func transactionSortCriteria(_ t1: TransactionDetails, _ t2: TransactionDetails) -> Bool {
        let date1 = t1.confirmationTime?.timestamp ?? t1.received
        let date2 = t2.confirmationTime?.timestamp ?? t2.received
        return date1 > date2
    }
}

private extension View {
    func paddingVertical() -> some View {
        self
            .padding(.vertical, 15.0)
            .padding(.vertical, 5.0)
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
