//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @State private var showingOnboardingViewErrorAlert = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                HeaderView()

                NetworkPickerView(
                    selectedNetwork: $viewModel.selectedNetwork,
                    selectedURL: $viewModel.selectedURL,
                    availableURLs: viewModel.availableURLs,
                    buttonColor: viewModel.buttonColor
                )
                .padding()

                SeedInputView(words: $viewModel.words, createWalletAction: viewModel.createWallet)
                    .padding(.top, 30)

                Spacer()

                FooterView()
                    .padding(.horizontal, 32)
            }
        }
        .alert(isPresented: $showingOnboardingViewErrorAlert) {
            Alert(
                title: Text("Onboarding Error"),
                message: Text(viewModel.onboardingViewError?.localizedDescription ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.onboardingViewError = nil
                }
            )
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "bitcoinsign.circle")
                .resizable()
                .foregroundColor(.bitcoinOrange)
                .frame(width: 100, height: 100, alignment: .center)
            Text("Bitcoin Wallet")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
            Text("CypherPunk Culture.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(0.3)
        }
    }
}

struct NetworkPickerView: View {
    @Binding var selectedNetwork: Network
    @Binding var selectedURL: String
    let availableURLs: [String]
    let buttonColor: Color

    var body: some View {
        VStack {
            Text("Choose your Network.")
                .font(.subheadline)
                .multilineTextAlignment(.center)

            VStack {
                Picker("Network", selection: $selectedNetwork) {
                    Text("Bitcoin").tag(Network.bitcoin)
                    Text("Testnet").tag(Network.testnet)
                    Text("Signet").tag(Network.signet)
                    Text("Regtest").tag(Network.regtest)
                }
                .pickerStyle(.automatic)
                .tint(buttonColor)

                Picker("Esplora Server", selection: $selectedURL) {
                    if availableURLs.isEmpty {
                        Text("No available URLs").tag("")
                    } else {
                        ForEach(availableURLs, id: \.self) { url in
                            Text(url.replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: ""))
                            .tag(url)
                        }
                    }
                }
                .pickerStyle(.automatic)
                .tint(buttonColor)
            }
        }
    }
}

struct SeedInputView: View {
    @Binding var words: String
    let createWalletAction: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            TextField("12 Word Seed Phrase (Optional)", text: $words)
                .submitLabel(.done)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
            Button("Create Wallet") {
                createWalletAction()
            }
            .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
        }
    }
}

struct FooterView: View {
    var body: some View {
        VStack {
            Text("EskyLab")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Text("100% open-source & open-design ₿")
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
#Preview("OnboardingView - en") {
    OnboardingView(viewModel: .init(bdkClient: .mock))
}

#Preview("OnboardingView - en - Large") {
    OnboardingView(viewModel: .init(bdkClient: .mock))
        .environment(\.sizeCategory, .accessibilityLarge)
}

#Preview("OnboardingView - fr") {
    OnboardingView(viewModel: .init(bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
#endif
