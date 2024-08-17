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
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [bitcoinOrange, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .shadow(radius: 10)

                    Text("Bitcoin Wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.horizontal, 12)

                    Text("CypherPunk Culture.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)

                // Network Picker
                VStack(spacing: 20) {
                    Text("Choose your Network.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Picker("Network", selection: $viewModel.selectedNetwork) {
                        Text("Bitcoin").tag(Network.bitcoin)
                        Text("Testnet").tag(Network.testnet)
                        Text("Signet").tag(Network.signet)
                        Text("Regtest").tag(Network.regtest)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .tint(viewModel.buttonColor)
                    .foregroundColor(.black)

                    Picker("Esplora Server", selection: $viewModel.selectedURL) {
                        ForEach(viewModel.availableURLs, id: \.self) { url in
                            Text(
                                url.replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                            )
                            .tag(url)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .tint(viewModel.buttonColor)
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 40)

                // Seed Phrase Field
                VStack(spacing: 20) {
                    TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.5))
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
                    .buttonStyle(BitcoinFilled(tintColor: slateGray, isCapsule: true))
                    .padding(.horizontal, 40)
                    .shadow(radius: 5)
                }
                .padding(.top, 30)

                Spacer()

                // Footer
                VStack(spacing: 8) {
                    Text("BDKSwift + EskyLab")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 2)

                    Text("100% open-source & open-design ₿")
                        .font(.footnote)
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
                message: Text(viewModel.onboardingViewError?.localizedDescription ?? "Unknown error"),
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
