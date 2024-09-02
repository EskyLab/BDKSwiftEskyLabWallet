//
//  TransactionDetailsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import SwiftUI
import BitcoinDevKit

struct TransactionDetailsView: View {
    @ObservedObject var viewModel: TransactionDetailsViewModel
    @StateObject private var priceViewModel = PriceViewModel()
    let transaction: TransactionDetails
    let amount: UInt64

    @State private var isCopied = false

    var body: some View {
        VStack(spacing: 20) {
            transactionInfo
            transactionAmount
            Spacer()
            transactionActions
        }
        .padding()
        .onAppear {
            viewModel.getNetwork()
            viewModel.getEsploraUrl()
            priceViewModel.fetchBitcoinPrice()
        }
    }

    private var transactionInfo: some View {
        VStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .resizable()
                .foregroundColor(.bitcoinOrange)
                .frame(width: 50, height: 50)

            HStack(spacing: 5) {
                Text(transaction.sent > 0 ? "Send" : "Receive")
                    .fontWeight(.semibold)
                
                Text(transaction.confirmationTime == nil ? "Unconfirmed" : "Confirmed")
                    .foregroundColor(transaction.confirmationTime == nil ? .red : .green)
            }
            .font(.caption)

            if let height = transaction.confirmationTime?.height {
                Text("Block \(height.delimiter)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }

    private var transactionAmount: some View {
        VStack(spacing: 16) {
            HStack {
                Text(amount.delimiter)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("sats")
                    .foregroundColor(.secondary)
            }

            if let priceUSD = priceViewModel.bitcoinPriceUSD {
                let amountInBTC = Double(amount) / 100_000_000
                let amountInUSD = amountInBTC * priceUSD
                Text(String(format: "$%.2f", amountInUSD))
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                Text("Fetching price...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 4) {
                if let timestamp = transaction.confirmationTime?.timestamp {
                    Text(formatDate(from: timestamp))
                        .foregroundColor(.secondary)
                        .font(.callout)
                }

                if let fee = transaction.fee {
                    Text("\(fee) sats fee")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
            }
        }
    }

    private var transactionActions: some View {
        HStack {
            Button(action: openTransactionInBrowser) {
                Image(systemName: "safari")
                    .font(.title2)
                    .foregroundColor(.bitcoinOrange)
            }
            Spacer()

            Text(transaction.txid)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()

            Button(action: copyTransactionID) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.title2)
                    .foregroundColor(.bitcoinOrange)
            }
        }
        .font(.caption)
        .padding()
    }

    private func formatDate(from unixTime: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func openTransactionInBrowser() {
        guard let esploraURL = viewModel.esploraURL else { return }
        let urlString = "\(esploraURL)/tx/\(transaction.txid)".replacingOccurrences(of: "/api", with: "")
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func copyTransactionID() {
        UIPasteboard.general.string = transaction.txid
        provideCopyFeedback()
    }

    private func provideCopyFeedback() {
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
}
