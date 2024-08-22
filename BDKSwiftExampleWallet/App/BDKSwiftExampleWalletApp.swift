//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import BitcoinDevKit
import SwiftUI
import LocalAuthentication

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("isBiometricEnabled") var isBiometricEnabled: Bool = false
    @State private var isAuthenticated: Bool = false
    @State private var isShowingSplash: Bool = true // State to control splash screen visibility
    let bdkService: BDKClient = .live

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashScreenView(isShowingSplash: $isShowingSplash)
            } else if isOnboarding {
                OnboardingView(viewModel: .init())
            } else if isAuthenticated {
                TabHomeView(viewModel: .init())
            } else {
                if isBiometricEnabled {
                    Text("Authenticating...")
                        .onAppear {
                            authenticateUser { success in
                                isAuthenticated = success
                                if !success {
                                    handleAuthenticationFailure()
                                }
                            }
                        }
                } else {
                    Text("Biometric authentication is disabled. Please log in.")
                        .onAppear {
                            isAuthenticated = true
                        }
                }
            }
        }
    }

    func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            // Biometric authentication is not available
            completion(false)
        }
    }

    func handleAuthenticationFailure() {
        print("Authentication failed. Please try again or use an alternative login method.")
    }
}
