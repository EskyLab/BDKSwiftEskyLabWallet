//
//  BuildTransactionView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct BuildTransactionView: View {
    let amount: String
    let address: String
    let fee: Int
    @Bindable var viewModel: BuildTransactionViewModel
    @State private var isSent: Bool = false
    @State private var isError: Bool = false
    @Binding var shouldPopToRootView: Bool
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Spacer()

                    // Transaction Details
                    VStack(spacing: 8) {
                        DetailRow(title: "To", value: address)
                        DetailRow(title: "Send", value: amount.formattedWithSeparator)
                        DetailRow(title: "Fee", value: viewModel.txBuilderResult?.transactionDetails.fee?.delimiter ?? "...")
                        DetailRow(title: "Total", value: totalAmount)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                    .shadow(radius: 4)

                    Spacer()

                    // Send Button
                    if !isSent {
                        Button(action: sendTransaction) {
                            Text("Send")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundColor(isSent ? .white : .bitcoinOrange)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSent ? Color.red : Color.bitcoinOrange, lineWidth: 2)
                                )
                                .shadow(radius: 4)
                        }
                        .padding()
                    } else if isSent && viewModel.buildTransactionViewError == nil {
                        // Present SuccessView if transaction is successful
                        SuccessView(txid: viewModel.txBuilderResult?.transactionDetails.txid ?? "", onDismiss: {
                            // Set the shouldPopToRootView to true to trigger the navigation back to the wallet transactions view
                            self.shouldPopToRootView = true
                        })
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Transaction")
                .onAppear {
                    let feeRate: Float? = Float(fee)
                    if let rate = feeRate {
                        viewModel.buildTransaction(
                            address: address,
                            amount: UInt64(amount) ?? 0,
                            feeRate: rate
                        )
                    }
                }
                .alert(isPresented: $viewModel.showingBuildTransactionViewErrorAlert) {
                    Alert(
                        title: Text("Build Transaction Error"),
                        message: Text(viewModel.buildTransactionViewError?.description ?? "Unknown"),
                        dismissButton: .default(Text("OK")) {
                            viewModel.buildTransactionViewError = nil
                        }
                    )
                }
            }
            .onChange(of: shouldPopToRootView) { newValue in
                if newValue {
                    // Navigate back to the wallet transactions view
                    self.shouldPopToRootView = false // Reset to prevent multiple triggers
                    // Add your custom navigation logic here if needed
                }
            }
        }
    }

    private var totalAmount: String {
        guard let sentAmount = UInt64(amount),
              let feeAmount = viewModel.txBuilderResult?.transactionDetails.fee else {
            return "..."
        }
        let total = sentAmount + feeAmount
        return total.delimiter
    }

    private func sendTransaction() {
        let feeRate: Float? = Float(fee)
        if let rate = feeRate, let amt = UInt64(amount) {
            viewModel.buildTransactionViewError = nil
            viewModel.send(address: address, amount: amt, feeRate: rate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.viewModel.buildTransactionViewError == nil {
                    self.isSent = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        if self.isSent {
                            self.shouldPopToRootView = true // Trigger the navigation back
                        }
                    }
                } else {
                    self.isSent = false
                    self.isError = true
                }
            }
        } else {
            self.isError = true
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

struct SuccessView: View {
    let txid: String
    let onDismiss: () -> Void
    
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

            HStack {
                Text(txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = txid
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                        showCheckmark = false
                    }
                }) {
                    HStack {
                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .foregroundColor(.bitcoinOrange)
                }
            }
            .font(.caption)
            .padding()
            
            Button(action: onDismiss) {
                Text("Done")
                    .fontWeight(.bold)
                    .padding()
                    .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 2)
                    )
            }
            .padding()
        }
        .padding()
    }
}

#if DEBUG
    #Preview {
        BuildTransactionView(
            amount: "100000",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            fee: 17,
            viewModel: .init(
                bdkClient: BDKClient.mock
            ),
            shouldPopToRootView: .constant(false)
        )
    }

    #Preview {
        BuildTransactionView(
            amount: "100000",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            fee: 17,
            viewModel: .init(
                bdkClient: .mock
            ),
            shouldPopToRootView: .constant(false)
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
