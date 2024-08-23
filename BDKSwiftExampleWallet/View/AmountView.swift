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
    @State private var isActive: Bool = false

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 40) {
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

                    Spacer(minLength: 20)

                    GeometryReader { geometry in
                        let buttonSize = geometry.size.width / 4
                        VStack(spacing: buttonSize / 10) {
                            numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                            numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                            numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                            numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 300)

                    // Add extra padding to the bottom of the screen
                    Spacer(minLength: 80) // Adjust this value for more or less whitespace

                    Button {
                        feedbackGenerator.impactOccurred()
                        isActive = true
                    } label: {
                        Label(
                            title: { Text("Next").font(.headline) },
                            icon: { Image(systemName: "arrow.right") }
                        )
                        .labelStyle(.iconOnly)
                        .padding()
                        .background(Color(uiColor: .systemGray6), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: .separator), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .navigationDestination(isPresented: $isActive) {
                        AddressView(amount: numpadAmount, rootIsActive: $isActive)
                            .transition(.slide) // Add transition for AddressView
                            .animation(.easeInOut, value: isActive) // Animate transition
                    }
                }
                .padding()
                .task {
                    viewModel.getBalance()
                }
            }
            .onChange(of: isActive) { _, newValue in
                if !newValue {
                    numpadAmount = "0"
                }
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

    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 6) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
    }
}
