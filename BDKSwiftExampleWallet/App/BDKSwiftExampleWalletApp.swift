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
    @State private var hasAttemptedBiometricAuth: Bool = false  // To track if biometric auth has been attempted
    let bdkService: BDKClient = .live

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView(isShowingSplash: $isShowingSplash)
            } else if !isAuthenticated {
                // Attempt biometric authentication if enabled, otherwise proceed
                if isBiometricEnabled && !hasAttemptedBiometricAuth {
                    BiometricAuthView(authenticateUser: authenticateUser)
                } else {
                    // Biometric authentication is disabled, proceed to onboarding or main screen
                    OnboardingView(viewModel: .init())
                        .onAppear {
                            isAuthenticated = true
                        }
                }
            } else if isOnboarding {
                OnboardingView(viewModel: .init())
            } else {
                TabHomeView(viewModel: .init())
            }
        }
    }

    func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    hasAttemptedBiometricAuth = true  // Mark biometric auth as attempted
                    if success {
                        isAuthenticated = true
                        completion(true)
                    } else {
                        handleAuthenticationFailure(error: authenticationError as? LAError)
                        completion(false)
                    }
                }
            }
        } else {
            hasAttemptedBiometricAuth = true  // Mark biometric auth as attempted
            // Biometric is not available, proceed
            completion(false)
        }
    }

    func handleAuthenticationFailure(error: LAError?) {
        // If biometric fails, don't proceed
        print("Biometric authentication failed.")
    }
}

struct SplashScreenView: View {
    @Binding var isShowingSplash: Bool
    @State private var isAnimating = false
    @State private var showCulture = false
    @State private var isAuthenticated = false

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("bitcoin-btc-logo-2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 1.0), value: isAnimating)
                
                Text("CYPHERPUNK")
                    .font(.custom("SFProDisplay-Black", size: 40))
                    .foregroundColor(.primary)
                    .padding(.top, 16)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 2.0).delay(0.5), value: isAnimating)
                
                if showCulture {
                    Text("CULTURE")
                        .font(.custom("SFProDisplay-Black", size: 40))
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                        .opacity(showCulture ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8), value: showCulture)
                }

                Spacer()

                Spacer().frame(height: 60)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .onAppear {
            startAnimations()
            authenticateUser()
        }
    }
    
    private func startAnimations() {
        isAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCulture = true
            }
        }
    }

    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        proceedToNextScreen()
                    } else {
                        // Authentication failed, do not proceed
                        handleAuthenticationFailure()
                    }
                }
            }
        } else {
            // Biometric is not available, proceed
            proceedToNextScreen()
        }
    }
    
    private func proceedToNextScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                isShowingSplash = false
            }
        }
    }

    private func handleAuthenticationFailure() {
        // Handle what happens if biometric authentication fails
        print("Biometric authentication failed. Access denied.")
        // Optionally, you can show an alert or simply stop the app flow here
    }
}

struct BiometricAuthView: View {
    var authenticateUser: (@escaping (Bool) -> Void) -> Void

    var body: some View {
        Text("Authenticating...")
            .onAppear {
                authenticateUser { success in
                    if !success {
                        // Authentication failed, no further action
                        print("Biometric authentication failed. Access denied.")
                    }
                }
            }
    }
}
