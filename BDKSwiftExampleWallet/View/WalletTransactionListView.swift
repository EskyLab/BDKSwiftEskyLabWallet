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
            content
        }
        .listStyle(.plain)
    }

    private var content: some View {
        if transactionDetails.isEmpty {
            return AnyView(emptyStateView)
        } else {
            return AnyView(transactionListView)
        }
    }

    private var emptyStateView: some View {
        Group {
            if walletSyncState == .syncing {
                WalletTransactionsListItemView(transaction: mockTransactionDetail, isRedacted: true)
            } else {
                Text("No Transactions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .applyStandardRowStyle()
    }

    private var transactionListView: some View {
        ForEach(sortedTransactions, id: \.txid) { transaction in
            NavigationLink(
                destination: TransactionDetailsView(
                    viewModel: .init(),
                    transaction: transaction,
                    amount: UInt64(transactionAmount(for: transaction))
                )
            ) {
                WalletTransactionsListItemView(transaction: transaction)
            }
            .applyStandardRowStyle()
        }
    }

    private var sortedTransactions: [TransactionDetails] {
        transactionDetails.sorted {
            $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?.timestamp ?? $1.received
        }
    }

    private func transactionAmount(for transaction: TransactionDetails) -> Int {
        Int(transaction.sent > 0
            ? transaction.sent - transaction.received
            : transaction.received - transaction.sent)
    }
}

extension View {
    func applyStandardRowStyle() -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}

struct WalletTransactionsListItemView: View {
    let transaction: TransactionDetails
    let isRedacted: Bool
    @Environment(\.sizeCategory) var sizeCategory

    init(transaction: TransactionDetails, isRedacted: Bool = false) {
        self.transaction = transaction
        self.isRedacted = isRedacted
    }

    var body: some View {
        HStack(spacing: 15) {
            transactionIcon
            transactionDetailsView
            Spacer()
            transactionAmountView
        }
        .padding(.vertical, 10)
        .minimumScaleFactor(0.5)
    }

    private var transactionIcon: some View {
        Image(systemName: isRedacted ? "circle.fill" : transactionIconName)
            .font(.largeTitle)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                isRedacted ? Color.gray.opacity(0.5) : iconColor,
                Color.gray.opacity(0.05)
            )
    }

    private var transactionIconName: String {
        transaction.sent > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }

    private var iconColor: Color {
        transaction.confirmationTime != nil ? .bitcoinOrange : .secondary
    }

    private var transactionDetailsView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(transaction.txid)
                .truncationMode(.middle)
                .lineLimit(1)
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.title)
                .foregroundColor(.primary)

            Text(transaction.confirmationTime?.timestamp.toDate().formatted(.dateTime.day().month().hour().minute()) ?? "Unconfirmed")
                .lineLimit(sizeCategory > .accessibilityMedium ? 2 : 1)
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .redacted(reason: isRedacted ? .placeholder : [])
    }

    private var transactionAmountView: some View {
        Text(transactionAmount)
            .font(.subheadline)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .lineLimit(1)
            .foregroundColor(transaction.sent > 0 ? .red : .green)
            .redacted(reason: isRedacted ? .placeholder : [])
    }

    private var transactionAmount: String {
        transaction.sent > 0
            ? "- \(transaction.sent - transaction.received) sats"
            : "+ \(transaction.received - transaction.sent) sats"
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
