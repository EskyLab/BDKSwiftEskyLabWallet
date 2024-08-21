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
    @Bindable var viewModel: FeeViewModel
    @Binding var rootIsActive: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                    FeePickerItem(icon: "gauge.with.dots.needle.0percent", text: "No Priority - \(viewModel.recommendedFees?.minimumFee ?? 1)")
                        .tag(0)
                    FeePickerItem(icon: "gauge.with.dots.needle.33percent", text: "Low Priority - \(viewModel.recommendedFees?.hourFee ?? 1)")
                        .tag(1)
                    FeePickerItem(icon: "gauge.with.dots.needle.50percent", text: "Med Priority - \(viewModel.recommendedFees?.halfHourFee ?? 1)")
                        .tag(2)
                    FeePickerItem(icon: "gauge.with.dots.needle.67percent", text: "High Priority - \(viewModel.recommendedFees?.fastestFee ?? 1)")
                        .tag(3)
                }
                .pickerStyle(WheelPickerStyle()) // Use WheelPickerStyle for better readability on iPhones
                .padding(.horizontal)
                .background(Color(uiColor: .secondarySystemBackground)) // Adapt background color for dark mode
                .cornerRadius(10)
                .clipped()
                
                Text("Fee rate: \(viewModel.selectedFee ?? 1) sat/vb")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical)

                Spacer()
                
                NavigationLink(destination: BuildTransactionView(
                    amount: amount,
                    address: address,
                    fee: viewModel.selectedFee ?? 1,
                    viewModel: .init(),
                    shouldPopToRootView: $rootIsActive
                )) {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(uiColor: .systemFill)) // Adapt button background color for dark mode
                        .foregroundColor(.bitcoinOrange) // Text color to match branding
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.bitcoinOrange, lineWidth: 2) // Subtle border to enhance visibility
                        )
                }
                .buttonStyle(PlainButtonStyle()) // Ensure the button style is plain to match custom design
                .padding()

            }
            .padding()
            .navigationTitle("Fees")
            .task {
                await viewModel.getFees()
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
}

struct FeePickerItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24) // Adjust icon size for better visibility
            Text(text)
                .font(.body) // Adjust font size for readability
        }
        .padding(.vertical, 4) // Add vertical padding for better separation
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
