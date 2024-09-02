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
    @ObservedObject var viewModel: BuildTransactionViewModel // Change @Bindable to @ObservedObject
    @State var isSent: Bool = false
    @State var isError: Bool = false
    @Binding var shouldPopToRootView: Bool
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                transactionDetailsSection

                Spacer()

                if !isSent {
                    sendButton
                } else if isSent && viewModel.buildTransactionViewError == nil {
                    transactionSentView
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Transaction")
            .onAppear {
                let feeRate: Float? = Float(fee)
                if let rate = feeRate {
                    viewModel.buildTransaction(address: address, amount: UInt64(amount) ?? 0, feeRate: rate)
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
    }

    private var transactionDetailsSection: some View {
        VStack(spacing: 16) {
            transactionDetailRow(label: "To", value: address)
            transactionDetailRow(label: "Send", value: amount.formattedWithSeparator)
            transactionDetailRow(label: "Fee", value: feeText)
            transactionDetailRow(label: "Total", value: totalText)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    private func transactionDetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body.weight(.regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var feeText: String {
        if let fee = viewModel.txBuilderResult?.transactionDetails.fee {
            return fee.delimiter
        } else {
            return "..."
        }
    }

    private var totalText: String {
        if let sentAmount = UInt64(amount),
           let feeAmount = viewModel.txBuilderResult?.transactionDetails.fee {
            let total = sentAmount + feeAmount
            return total.delimiter
        } else {
            return "..."
        }
    }

    private var sendButton: some View {
        Button {
            sendTransaction()
        } label: {
            Label("Send", systemImage: "paperplane.fill")
                .labelStyle(.iconOnly)
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity) // Make the button take the full available width
                .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator), lineWidth: 2)
                )
        }
        .buttonStyle(.plain) // Consistent button style with custom design
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Haptic feedback
                }
        )
        .padding(.horizontal, 40) // Adjust the horizontal padding to control the width
        .padding(.bottom, 40) // Adjusts position to be centered vertically
        .disabled(isSent)
    }

    private func sendTransaction() {
        let feeRate: Float? = Float(fee)
        if let rate = feeRate, let amt = UInt64(amount) {
            viewModel.buildTransactionViewError = nil
            isSent = true
            viewModel.send(address: address, amount: amt, feeRate: rate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if viewModel.buildTransactionViewError == nil {
                    isSent = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        shouldPopToRootView = false
                    }
                } else {
                    isSent = false
                    isError = true
                }
            }
        } else {
            isError = true
        }
    }

    private var transactionSentView: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .padding()

            if let transaction = viewModel.txBuilderResult?.transactionDetails {
                HStack {
                    Text(transaction.txid)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .fontDesign(.monospaced)
                        .font(.caption)

                    Spacer()

                    Button {
                        copyTransactionID(transaction.txid)
                    } label: {
                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            .foregroundColor(showCheckmark ? .green : .primary)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    private func copyTransactionID(_ txid: String) {
        UIPasteboard.general.string = txid
        isCopied = true
        showCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
            showCheckmark = false
        }
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
