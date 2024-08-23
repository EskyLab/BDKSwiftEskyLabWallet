//
//  AddressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import SwiftUI
import CodeScanner

struct AddressView: View {
    let amount: String
    @State private var address: String = ""
    @Binding var rootIsActive: Bool
    @State private var isShowingScanner = false
    let pasteboard = UIPasteboard.general
    @State private var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Haptic feedback generator

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: {
                            impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback
                            isShowingScanner = true
                        }) {
                            Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                                .font(.title2)
                                .padding()
                                .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                                )
                        }

                        Button(action: {
                            impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback
                            handlePasteboard()
                        }) {
                            Label("Paste", systemImage: "doc.on.doc")
                                .font(.title2)
                                .padding()
                                .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Address")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal, 15)

                        TextField(
                            "Enter address to send BTC to",
                            text: $address
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .separator), lineWidth: 1)
                        )
                        .font(.title3)
                        .foregroundColor(.primary)
                    }

                    NavigationLink(destination: FeeView(
                        amount: amount,
                        address: address,
                        viewModel: .init(),
                        rootIsActive: self.$rootIsActive
                    )) {
                        Label("Next", systemImage: "arrow.right")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .padding()
                            .background(Color(uiColor: .systemFill), in: RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.bitcoinOrange) // Change foreground color
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.bitcoinOrange, lineWidth: 2) // Change outline color
                            )
                    }
                    .buttonStyle(.plain) // Ensures button style remains consistent with custom design
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback
                            }
                    )
                }
                .padding()
                .navigationTitle("Address")
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.qr],
                simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                completion: handleScan
            )
        }
    }

    private func handlePasteboard() {
        if pasteboard.hasStrings, let string = pasteboard.string {
            address = string.lowercased()
        } else {
            // TODO: handle error
        }
    }

    private func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let scannedAddress = result.string.lowercased().replacingOccurrences(
                of: "bitcoin:",
                with: ""
            )
            let components = scannedAddress.components(separatedBy: "?")
            if let bitcoinAddress = components.first {
                address = bitcoinAddress
            } else {
                // TODO: handle error
            }
        case .failure(_):
            print("TODO: handle error")
        }
    }
}

#Preview {
    AddressView(amount: "200", rootIsActive: .constant(false))
}

#Preview {
    AddressView(amount: "200", rootIsActive: .constant(false))
        .environment(\.sizeCategory, .accessibilityLarge)
}
