//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import BitcoinUI
import SwiftUI

struct ReceiveView: View {
    @Bindable var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {

        ZStack {
            // Background color
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header with Bitcoin icon and title
                VStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .frame(width: 50, height: 50)
                        .font(.title)
                    Text("Receive Address")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 40.0)
                
                Spacer()
                
                // QR Code View
                if viewModel.address.isEmpty {
                    QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                        .blur(radius: 15)
                        .transition(.opacity)
                } else {
                    QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Address and copy button
                HStack {
                    Text(viewModel.address.isEmpty ? "No address" : viewModel.address)
                        .font(.body.monospaced())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Button {
                        UIPasteboard.general.string = viewModel.address
                        isCopied = true
                        showCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isCopied = false
                            showCheckmark = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.bitcoinOrange)
                        }
                    }
                }
                .padding()
                .font(.caption)
            }
            .padding()
            .onAppear {
                viewModel.getAddress()
            }
        }
        .alert(isPresented: $viewModel.showingReceiveViewErrorAlert) {
            Alert(
                title: Text("Receive Error"),
                message: Text(viewModel.receiveViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.receiveViewError = nil
                }
            )
        }
    }
}

#if DEBUG
    #Preview("ReceiveView - en") {
        ReceiveView(viewModel: .init(bdkClient: .mock))
    }

    #Preview("ReceiveView - en - Large") {
        ReceiveView(viewModel: .init(bdkClient: .mock))
            .environment(\.sizeCategory, .accessibilityLarge)
    }

    #Preview("ReceiveView - fr") {
        ReceiveView(viewModel: .init(bdkClient: .mock))
            .environment(\.locale, .init(identifier: "fr"))
    }
#endif
