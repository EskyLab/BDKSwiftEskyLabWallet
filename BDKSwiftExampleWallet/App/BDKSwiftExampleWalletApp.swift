//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI
import LocalAuthentication
import BitcoinDevKit

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("isBiometricEnabled") var isBiometricEnabled: Bool = false
    @State private var isAuthenticated: Bool = false
    @State private var isShowingSplash: Bool = true
    @State private var hasAttemptedBiometricAuth: Bool = false  // Track if biometric auth has been attempted
    @State private var hasAuthenticatedSuccessfully: Bool = false  // Track if biometric auth was successful

    let bdkService: BDKClient = .live

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView(isShowingSplash: $isShowingSplash, authenticateUser: authenticateUser)
            } else if !isAuthenticated {
                if isBiometricEnabled && !hasAuthenticatedSuccessfully {
                    // If biometric is enabled and has not been successfully authenticated, show BiometricAuthView
                    BiometricAuthView(authenticateUser: authenticateUser)
                } else {
                    // Proceed directly to onboarding or main screen if already authenticated
                    proceedToMainContent()
                }
            } else {
                proceedToMainContent()
            }
        }
    }

    func authenticateUser(completion: @escaping (Bool) -> Void) {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.hasAuthenticatedSuccessfully = true
            completion(true)
        }
        #else
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    hasAttemptedBiometricAuth = true
                    if success {
                        isAuthenticated = true
                        hasAuthenticatedSuccessfully = true
                        completion(true)
                    } else {
                        handleAuthenticationFailure(error: authenticationError as? LAError)
                        completion(false)
                    }
                }
            }
        } else {
            hasAttemptedBiometricAuth = true
            completion(false)
        }
        #endif
    }

    func handleAuthenticationFailure(error: LAError?) {
        print("Biometric authentication failed.")
    }

    @ViewBuilder
    func proceedToMainContent() -> some View {
        if isOnboarding {
            OnboardingView(viewModel: .init())
        } else {
            TabHomeView(viewModel: .init())
        }
    }
    
    struct BiometricAuthView: View {
        var authenticateUser: (@escaping (Bool) -> Void) -> Void

        var body: some View {
            Text("Authenticating...")
                .onAppear {
                    authenticateUser { success in
                        if !success {
                            print("Biometric authentication failed. Access denied.")
                        }
                    }
                }
        }
    }
    
    struct SplashScreenView: View {
        @Binding var isShowingSplash: Bool
        @State private var isAnimating = false
        @State private var showCulture = false
        var authenticateUser: (@escaping (Bool) -> Void) -> Void

        var body: some View {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack {
                    Spacer()

                    Image("bitcoin-btc-logo-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 2.0), value: isAnimating)

                    Text("CYPHERPUNK")
                        .font(.custom("SFProDisplay-Black", size: 40))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 2.5).delay(1.0), value: isAnimating)

                    if showCulture {
                        Text("CULTURE")
                            .font(.custom("SFProDisplay-Black", size: 40))
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                            .opacity(showCulture ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 1.5).delay(0.5), value: showCulture)
                    }

                    Spacer()

                    Spacer().frame(height: 60)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .onAppear {
                startAnimations()
                authenticateUser { success in
                    if success {
                        proceedToNextScreen()
                    } else {
                        handleAuthenticationFailure()
                    }
                }
            }
        }

        private func startAnimations() {
            isAnimating = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showCulture = true
                }
            }
        }

        private func proceedToNextScreen() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }

        private func handleAuthenticationFailure() {
            print("Biometric authentication failed. Access denied.")
        }
    }
}
