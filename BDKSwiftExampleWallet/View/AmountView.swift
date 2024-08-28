//
//  AmountView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import SwiftUI

struct AmountView: View {
    @ObservedObject var viewModel: AmountViewModel
    @State private var numpadAmount = "0"
    @State private var isNextActive = false

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 8) {
                    Text("\(numpadAmount.formattedWithSeparator) sats")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.primary)

                    if let balance = viewModel.balanceTotal {
                        HStack(spacing: 2) {
                            Text(balance.delimiter)
                            Text("Total")
                        }
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    }

                    if let balance = viewModel.balanceConfirmed {
                        HStack(spacing: 2) {
                            Text(balance.delimiter)
                            Text("Confirmed")
                        }
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                VStack(spacing: 10) {
                    numpadRow(["1", "2", "3"])
                    numpadRow(["4", "5", "6"])
                    numpadRow(["7", "8", "9"])
                    numpadRow([" ", "0", "<"])
                }
                .padding(.horizontal, 40)

                // Updated iOS-style Next button below the numpad
                Button(action: {
                    impactFeedbackGenerator.impactOccurred()
                    isNextActive = true
                }) {
                    Label("Next", systemImage: "arrow.right")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .padding()
                        .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .separator), lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            impactFeedbackGenerator.impactOccurred()
                        }
                )
                .navigationDestination(isPresented: $isNextActive) {
                    AddressView(amount: numpadAmount, rootIsActive: $isNextActive)
                }
                .padding(.bottom, 40) // Adjust this padding to control spacing from the bottom of the screen
            }
            .padding()
            .task {
                viewModel.getBalance()
            }
        }
        .alert(isPresented: $viewModel.showingAmountViewErrorAlert) {
            Alert(
                title: Text("Amount Error"),
                message: Text(viewModel.amountViewError?.description ?? "Unknown Error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.amountViewError = nil
                }
            )
        }
    }

    func numpadRow(_ characters: [String]) -> some View {
        HStack(spacing: 20) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: 80, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
    }
}
