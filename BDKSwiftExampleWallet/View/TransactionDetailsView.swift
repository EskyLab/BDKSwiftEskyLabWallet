//
//  TransactionDetailsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct TransactionDetailsView: View {
    @ObservedObject var viewModel: TransactionDetailsViewModel

    let transaction: TransactionDetails
    let amount: UInt64
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 20) {
            // Transaction Type and Confirmation Status
            VStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .foregroundColor(.bitcoinOrange)
                    .frame(width: 50, height: 50)
                
                HStack(spacing: 5) {
                    Text(transaction.sent > 0 ? "Send" : "Receive")
                        .fontWeight(.semibold)
                    
                    if transaction.confirmationTime == nil {
                        Text("Unconfirmed")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Confirmed")
                            .foregroundColor(.green) // Green for confirmed
                    }
                }
                .font(.caption)
                
                if let height = transaction.confirmationTime?.height {
                    Text("Block \(height.delimiter)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // Amount and Details
            VStack(spacing: 16) {
                HStack {
                    Text(amount.delimiter)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("sats")
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    if transaction.confirmationTime == nil {
                        Text("Unconfirmed")
                            .foregroundColor(.secondary)
                            .font(.callout)
                    } else {
                        if let timestamp = transaction.confirmationTime?.timestamp {
                            Text(timestamp.toDate().formatted(
                                date: .abbreviated,
                                time: .shortened
                            ))
                            .foregroundColor(.secondary)
                            .font(.callout)
                        }
                    }

                    if let fee = transaction.fee {
                        Text("\(fee) sats fee")
                            .foregroundColor(.secondary)
                            .font(.callout)
                    }
                }
            }

            Spacer()

            // Transaction ID and Actions
            HStack {
                if viewModel.network != Network.regtest.description {
                    Button(action: {
                        if let esploraURL = viewModel.esploraURL {
                            let urlString = "\(esploraURL)/tx/\(transaction.txid)"
                                .replacingOccurrences(of: "/api", with: "")
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }) {
                        Image(systemName: "safari")
                            .font(.title2)
                            .foregroundColor(.bitcoinOrange)
                    }
                    Spacer()
                }
                
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.caption)
                    .foregroundColor(.primary)
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = transaction.txid
                    isCopied = true
                    withAnimation {
                        showCheckmark = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                            showCheckmark = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            .font(.title2)
                            .foregroundColor(.bitcoinOrange)
                    }
                }
            }
            .font(.caption)
            .padding()
        }
        .padding()
        .onAppear {
            viewModel.getNetwork()
            viewModel.getEsploraUrl()
        }
    }
}

#Preview {
    TransactionDetailsView(
        viewModel: .init(),
        transaction: mockTransactionDetail,
        amount: UInt64(10_000_000)
    )
}

#Preview {
    TransactionDetailsView(
        viewModel: .init(),
        transaction: mockTransactionDetail,
        amount: UInt64(10_000_000)
    )
    .environment(\.sizeCategory, .accessibilityLarge)
}
