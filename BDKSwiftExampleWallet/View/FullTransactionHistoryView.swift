//
//  FullTransactionHistoryView.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 27/08/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import BitcoinDevKit
import SwiftUI

struct FullTransactionHistoryView: View {
    let transactionDetails: [TransactionDetails]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(
                    transactionDetails
                        .filter { $0.confirmationTime != nil } // Filter out unconfirmed transactions
                        .sorted(by: {
                            $0.confirmationTime!.timestamp > $1.confirmationTime!.timestamp
                        }),
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
                        transactionRow(for: transaction)
                    }
                }
            }
            .navigationTitle("All Transactions")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .listStyle(.plain)
        }
    }

    private func transactionRow(for transaction: TransactionDetails) -> some View {
        HStack(spacing: 15) {
            Image(systemName: transaction.sent > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color.bitcoinOrange,
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

                Text(
                    transaction.confirmationTime!.timestamp.toDate().formatted(.dateTime.day().month().hour().minute())
                )
                .foregroundColor(.secondary)
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
