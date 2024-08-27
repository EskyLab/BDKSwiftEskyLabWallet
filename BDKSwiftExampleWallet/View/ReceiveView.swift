//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import BitcoinUI
import SwiftUI
import MessageUI

struct ReceiveView: View {
    @Bindable var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showMessageCompose = false
    @State private var showMailCompose = false
    @State private var showAlert = false
    @State private var showMailErrorAlert = false
    @State private var showMessageErrorAlert = false

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
                        showAlert = true
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
            .confirmationDialog("What would you like to do?", isPresented: $showAlert) {
                Button("Copy Address") {
                    UIPasteboard.general.string = viewModel.address
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                        showCheckmark = false
                    }
                }
                Button("Share via iMessage") {
                    if MFMessageComposeViewController.canSendText() {
                        showMessageCompose = true
                    } else {
                        showMessageErrorAlert = true
                    }
                }
                Button("Share via Email") {
                    if MFMailComposeViewController.canSendMail() {
                        showMailCompose = true
                    } else {
                        showMailErrorAlert = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showMessageCompose) {
                MessageComposeView(address: viewModel.address)
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(address: viewModel.address)
            }
            .alert("Cannot Send Mail", isPresented: $showMailErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This device is not configured to send emails.")
            }
            .alert("Cannot Send Messages", isPresented: $showMessageErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This device is not configured to send iMessages.")
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

// View for MessageCompose
struct MessageComposeView: UIViewControllerRepresentable {
    let address: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.body = "Here's my Bitcoin address: \(address)"
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView

        init(_ parent: MessageComposeView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }
}

// View for MailCompose
struct MailComposeView: UIViewControllerRepresentable {
    let address: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject("My Bitcoin Address")
        vc.setMessageBody("Here's my Bitcoin address: \(address)", isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView

        init(_ parent: MailComposeView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
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
