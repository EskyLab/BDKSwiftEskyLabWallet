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
                        HStack {
                            Text("To")
                                .font(.headline)
                            Spacer()
                            Text(address)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        HStack {
                            Text("Send")
                                .font(.headline)
                            Spacer()
                            Text(amount.formattedWithSeparator)
                                .font(.headline)
                        }
                        HStack {
                            Text("Fee")
                                .font(.headline)
                            Spacer()
                            if let fee = viewModel.txBuilderResult?.transactionDetails.fee {
                                Text(fee.delimiter)
                                    .font(.headline)
                            } else {
                                Text("...")
                                    .font(.headline)
                            }
                        }
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            if let sentAmount = UInt64(amount),
                               let feeAmount = viewModel.txBuilderResult?.transactionDetails.fee
                            {
                                let total = sentAmount + feeAmount
                                Text(total.delimiter)
                                    .font(.headline)
                            } else {
                                Text("...")
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
                    .shadow(radius: 4)

                    Spacer()

                    // Send Button
                    if !isSent {
                        Button(action: {
                            let feeRate: Float? = Float(fee)
                            if let rate = feeRate {
                                if let amt = UInt64(amount) {
                                    viewModel.buildTransactionViewError = nil
                                    viewModel.send(
                                        address: address,
                                        amount: amt,
                                        feeRate: rate
                                    )
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        if self.viewModel.buildTransactionViewError == nil {
                                            self.isSent = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                self.shouldPopToRootView = false
                                            }
                                        } else {
                                            self.isSent = false
                                            self.isError = true
                                        }
                                    }
                                } else {
                                    self.isError = true
                                }
                            } else {
                                self.isError = true
                            }
                        }) {
                            Text("Send")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.all, 12)
                                .background(isSent ? Color.red : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        }
                        .padding()
                    } else if isSent && viewModel.buildTransactionViewError == nil {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                            if let transaction = viewModel.txBuilderResult?.transactionDetails {
                                HStack {
                                    Text(transaction.txid)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button(action: {
                                        UIPasteboard.general.string = transaction.txid
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
                                        .foregroundColor(.orange)
                                    }
                                }
                                .font(.caption)
                                .padding()
                            }
                        }
                        .padding()
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
