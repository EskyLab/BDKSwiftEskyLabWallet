//
//  AddressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import SwiftUI
import CodeScanner
import BitcoinUI

struct AddressView: View {
    let amount: String
    @State private var address: String = ""
    @Binding var rootIsActive: Bool
    @State private var isShowingScanner = false
    let pasteboard = UIPasteboard.general

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                                .font(.title2)
                        }
                        
                        Button(action: {
                            handlePasteboard()
                        }) {
                            Label("Paste", systemImage: "doc.on.doc")
                                .font(.title2)
                        }
                    }
                    .padding(.top)
                    .sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(
                            codeTypes: [.qr],
                            simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                            completion: handleScan
                        )
                    }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Address")
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        
                        TextField(
                            "Enter address to send BTC to",
                            text: $address
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .lineLimit(1)
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
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain) // Ensure the button style is plain to match custom design
                }
                .padding()
                .navigationTitle("Address")
            }
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
