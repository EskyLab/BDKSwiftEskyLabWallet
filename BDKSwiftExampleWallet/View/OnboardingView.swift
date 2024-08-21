//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import BitcoinDevKit
import BitcoinUI
import LocalAuthentication

func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
    let context = LAContext()
    var error: NSError?

    // Check if the device supports biometric authentication
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        let reason = "Authenticate to secure your wallet"

        // Attempt to authenticate the user
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    completion(false, authenticationError)
                }
            }
        }
    } else {
        // Biometric authentication not available
        completion(false, error)
    }
}

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @State private var showingOnboardingViewErrorAlert = false
    @State private var authenticationError: Error?

    // Define custom colors with iOS 18 design principles
    private let matteBlack = Color(red: 26/255, green: 26/255, blue: 26/255) // Matte black for dark mode
    private let slateGray = Color(red: 48/255, green: 48/255, blue: 48/255) // Slate gray for UI elements
    private let lightBackground = Color(uiColor: .systemBackground) // Adaptive background color
    private let darkTextColor = Color(uiColor: .label) // Adaptive label color for dark text
    private let lightTextColor = Color(uiColor: .systemBackground) // Adaptive background color for light text
    private let mutedTextColor = Color.gray.opacity(0.7) // Muted text color

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive Background Color
                lightBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        Spacer(minLength: 30)

                        // Logo and Title
                        VStack(spacing: 20) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(darkTextColor)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 10)

                            Text("Bitcoin Wallet")
                                .font(.largeTitle.bold())
                                .foregroundColor(darkTextColor)
                                .shadow(radius: 5)
                                .padding(.horizontal, 12)

                            Text("CypherPunk Culture.")
                                .font(.headline)
                                .foregroundColor(mutedTextColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)

                        // Network Picker
                        VStack(spacing: 20) {
                            Text("Choose your Network.")
                                .font(.headline)
                                .foregroundColor(darkTextColor)
                                .multilineTextAlignment(.center)

                            Picker("Network", selection: $viewModel.selectedNetwork) {
                                Text("Bitcoin").tag(Network.bitcoin)
                                Text("Testnet").tag(Network.testnet)
                                Text("Signet").tag(Network.signet)
                                Text("Regtest").tag(Network.regtest)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(slateGray)
                            .cornerRadius(10)
                            .tint(viewModel.buttonColor)
                            .foregroundColor(lightTextColor)

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
                            .background(slateGray)
                            .cornerRadius(10)
                            .tint(viewModel.buttonColor)
                            .foregroundColor(lightTextColor)
                        }
                        .padding(.horizontal, 40)

                        // Seed Phrase Field and Create Wallet Button
                        VStack(spacing: 20) {
                            TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(slateGray)
                                .foregroundColor(lightTextColor)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lightTextColor.opacity(0.8), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                                .padding(.horizontal, 40)

                            Button(action: {
                                // Trigger biometric authentication before creating the wallet
                                authenticateUser { success, error in
                                    if success {
                                        viewModel.createWallet()
                                    } else {
                                        self.authenticationError = error
                                        self.showingOnboardingViewErrorAlert = true
                                    }
                                }
                            }) {
                                Text("Create Wallet")
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .black : .white) // Inverse the text color based on the mode
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 40)
                                    .background(colorScheme == .dark ? .white : .black) // Inverse the button background based on the mode
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
                                .foregroundColor(darkTextColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .shadow(radius: 2)

                            Text("100% open-source & open-design ₿")
                                .font(.footnote)
                                .foregroundColor(darkTextColor.opacity(0.7))
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
                title: Text("Authentication Failed"),
                message: Text("Unable to authenticate using Face ID/Touch ID. Please try again or check your device settings."),
                dismissButton: .default(Text("OK"))
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
