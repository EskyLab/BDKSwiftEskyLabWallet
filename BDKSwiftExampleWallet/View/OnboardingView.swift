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
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @State private var showingOnboardingViewErrorAlert = false

    // Define custom colors
    private let bitcoinOrange = Color(red: 247/255, green: 147/255, blue: 26/255) // #f7931a
    private let slateGray = Color(red: 77/255, green: 77/255, blue: 77/255) // #4d4d4d

    var body: some View {
        ZStack {
            // Gradient background from Bitcoin Orange to Black
            LinearGradient(
                gradient: Gradient(colors: [bitcoinOrange, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 25) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100, alignment: .center)
                        .shadow(radius: 10)

                    Text("Bitcoin Wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text("CypherPunk Culture.")
                        .textStyle(BitcoinBody1())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }

                VStack {

                    Text("Choose your Network.")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    VStack {
                        Picker(
                            "Network",
                            selection: $viewModel.selectedNetwork
                        ) {
                            Text("Bitcoin").tag(Network.bitcoin)
                            Text("Testnet").tag(Network.testnet)
                            Text("Signet").tag(Network.signet)
                            Text("Regtest").tag(Network.regtest)
                        }
                        .pickerStyle(.segmented)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .tint(viewModel.buttonColor)

                        Picker(
                            "Esplora Server",
                            selection: $viewModel.selectedURL
                        ) {
                            ForEach(viewModel.availableURLs, id: \.self) { url in
                                Text(
                                    url.replacingOccurrences(
                                        of: "https://",
                                        with: ""
                                    ).replacingOccurrences(
                                        of: "http://",
                                        with: ""
                                    )
                                )
                                .tag(url)
                            }
                        }
                        .pickerStyle(.automatic)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .tint(viewModel.buttonColor)
                    }

                }
                .padding()

                VStack(spacing: 25) {
                    TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.5)) // Darker translucent background
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(radius: 5)
                        .padding(.horizontal, 40)

                    Button("Create Wallet") {
                        viewModel.createWallet()
                    }
                    .buttonStyle(BitcoinFilled(tintColor: slateGray, isCapsule: true)) // Slate Gray button
                    .padding(.horizontal)
                    .shadow(radius: 5)
                }
                .padding(.top, 30)

                Spacer()

                VStack {
                    Text("BDKSwift + EskyLab")
                        .textStyle(BitcoinBody4())
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 2)

                    Text("100% open-source & open-design ₿")
                        .textStyle(BitcoinBody4())
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 2)
                }
                .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))
            }
        }
        .alert(isPresented: $showingOnboardingViewErrorAlert) {
            Alert(
                title: Text("Onboarding Error"),
                message: Text(viewModel.onboardingViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.onboardingViewError = nil
                }
            )
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






