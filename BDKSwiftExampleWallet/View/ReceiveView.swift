//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI
import MessageUI
import BitcoinUI

struct ReceiveView: View {
    @Bindable var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showMessageCompose = false
    @State private var showMailCompose = false
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var showMailErrorAlert = false
    @State private var showMessageErrorAlert = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
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
                
                QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                    .blur(radius: viewModel.address.isEmpty ? 15 : 0)
                    .transition(.opacity)
                
                Spacer()
                
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
                Task {
                    await viewModel.getAddress()
                }
            }
            .confirmationDialog("What would you like to do?", isPresented: $showAlert) {
                Button("Copy Address") {
                    copyAddressToClipboard()
                }
                Button("Share via iMessage") {
                    showMessageCompose = MFMessageComposeViewController.canSendText()
                    showMessageErrorAlert = !showMessageCompose
                }
                Button("Share via Email") {
                    showMailCompose = MFMailComposeViewController.canSendMail()
                    showMailErrorAlert = !showMailCompose
                }
                Button("Share via AirDrop") {
                    showShareSheet = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showMessageCompose) {
                MessageComposeView(address: viewModel.address)
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(address: viewModel.address)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [viewModel.address])
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

    // Encapsulate the address copy logic
    private func copyAddressToClipboard() {
        UIPasteboard.general.string = viewModel.address
        isCopied = true
        showCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
            showCheckmark = false
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

// View for ShareSheet (AirDrop and others)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
