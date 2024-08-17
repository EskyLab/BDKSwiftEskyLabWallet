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
    private let matteBlack = Color(red: 26/255, green: 26/255, blue: 26/255) // Matte black background
    private let slateGray = Color(red: 48/255, green: 48/255, blue: 48/255) // Slate gray background
    private let lightBackground = Color.white // Light gray for light mode
    private let darkTextColor = Color(red: 30/255, green: 30/255, blue: 30/255) // Dark text for light mode
    private let lightTextColor = Color.white // Light text for dark mode
    private let mutedTextColor = Color.gray.opacity(0.7) // Muted text color

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color with matte black for dark mode and light gray for light mode
                (colorScheme == .dark ? matteBlack : lightBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        Spacer(minLength: 30)

                        // Logo and Title
                        VStack(spacing: 20) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 10)

                            Text("Bitcoin Wallet")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(radius: 5)
                                .padding(.horizontal, 12)

                            Text("CypherPunk Culture.")
                                .font(.headline)
                                .foregroundColor(mutedTextColor) // Muted text color
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)

                        // Network Picker
                        VStack(spacing: 20) {
                            Text("Choose your Network.")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .multilineTextAlignment(.center)

                            Picker("Network", selection: $viewModel.selectedNetwork) {
                                Text("Bitcoin").tag(Network.bitcoin)
                                Text("Testnet").tag(Network.testnet)
                                Text("Signet").tag(Network.signet)
                                Text("Regtest").tag(Network.regtest)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(colorScheme == .dark ? slateGray : Color.white) // Adapt background color
                            .cornerRadius(10)
                            .tint(viewModel.buttonColor)
                            .foregroundColor(colorScheme == .dark ? .black : .black)

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
                            .background(colorScheme == .dark ? slateGray : Color.white) // Adapt background color
                            .cornerRadius(10)
                            .tint(viewModel.buttonColor)
                            .foregroundColor(colorScheme == .dark ? .black : .black)
                        }
                        .padding(.horizontal, 40)

                        // Seed Phrase Field and Create Wallet Button
                        VStack(spacing: 20) {
                            TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(colorScheme == .dark ? slateGray : Color.white) // Adapt background color
                                .foregroundColor(colorScheme == .dark ? lightTextColor : darkTextColor) // Adapt text color
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(colorScheme == .dark ? lightTextColor.opacity(0.8) : darkTextColor.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)

                            Button(action: {
                                viewModel.createWallet()
                            }) {
                                Text("Create Wallet")
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .black : .white) // Adapt text color
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 40)
                                    .background(colorScheme == .dark ? lightTextColor : darkTextColor) // Adapt button background
                                    .clipShape(Capsule())
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 30)

                        Spacer(minLength: 30)

                        // Footer
                        VStack(spacing: 8) {
                            Text("BDKSwift + EskyLab")
                                .font(.footnote)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                                .shadow(radius: 2)

                            Text("100% open-source & open-design ₿")
                                .font(.footnote)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                                .shadow(radius: 2)
                        }
                        .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))
                    }
                }
            }
            .navigationTitle("Onboarding")
            .navigationBarTitleDisplayMode(.inline)
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





