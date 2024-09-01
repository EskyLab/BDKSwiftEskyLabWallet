//
//  FeeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct FeeView: View {
    let amount: String
    let address: String
    @ObservedObject var viewModel: FeeViewModel  // Corrected from @Bindable to @ObservedObject
    @Binding var rootIsActive: Bool
    @State private var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Haptic feedback generator

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Spacer()
                    Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.0percent")
                            Text(" No Priority - \(viewModel.recommendedFees?.minimumFee ?? 1)")
                        }
                        .tag(0)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.33percent")
                            Text(" Low Priority - \(viewModel.recommendedFees?.hourFee ?? 1)")
                        }
                        .tag(1)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.50percent")
                            Text(" Med Priority - \(viewModel.recommendedFees?.halfHourFee ?? 1)")
                        }
                        .tag(2)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                            Text(" High Priority - \(viewModel.recommendedFees?.fastestFee ?? 1)")
                        }
                        .tag(3)
                    }
                    .pickerStyle(.automatic)
                    .tint(.primary) // Use primary color that adapts to the system mode
                    Text("sat/vb")
                        .foregroundColor(.secondary)
                        .fontWeight(.thin)
                    Spacer()
                }

                Spacer()

                // Centered "Next" button below the Picker
                NavigationLink(
                    destination: BuildTransactionView(
                        amount: amount,
                        address: address,
                        fee: viewModel.selectedFee ?? 1,
                        viewModel: .init(),
                        shouldPopToRootView: self.$rootIsActive
                    )
                ) {
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
                .buttonStyle(.plain) // Ensures button style remains consistent with custom design
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback
                        }
                )
                .padding(.bottom, 40) // Adds space at the bottom

                Spacer()
            }
            .padding()
            .navigationTitle("Fees")
            .task {
                await viewModel.getFees()
            }
        }
        .alert(isPresented: $viewModel.showingFeeViewErrorAlert) {
            Alert(
                title: Text("Fee Error"),
                message: Text(viewModel.feeViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.feeViewError = nil
                }
            )
        }
    }
}

#if DEBUG
    #Preview {
        FeeView(
            amount: "50",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            viewModel: .init(feeClient: .mock, bdkClient: .mock),
            rootIsActive: .constant(false)
        )
    }

    #Preview {
        FeeView(
            amount: "50",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            viewModel: .init(feeClient: .mock, bdkClient: .mock),
            rootIsActive: .constant(false)
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
