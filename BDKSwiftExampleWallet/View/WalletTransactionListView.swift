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

    var body: some View {
        List {
            if transactionDetails.isEmpty && walletSyncState == .syncing {
                // Mock transaction for redacted state (loading state)
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
            } else if transactionDetails.isEmpty {
                Text("No Transactions")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(
                    transactionDetails.sorted(
                        by: {
                            $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?.timestamp ?? $1.received
                        }
                    ),
                    id: \.txid
                ) { transaction in
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
                                    transaction.confirmationTime != nil ? Color.bitcoinOrange : Color.secondary,
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

                            // Removed "+" and "-" from the transaction amount
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
        }
        .listStyle(.plain)
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
