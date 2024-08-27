//
//  SplashScreenView.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 22/08/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import SwiftUI
import LocalAuthentication

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
            isAnimating = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCulture = true
                }
            }
            
            authenticateUser()
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
                        proceedToNextScreen()
                    }
                }
            }
        } else {
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
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isShowingSplash: .constant(true))
            .preferredColorScheme(.light)
        SplashScreenView(isShowingSplash: .constant(true))
            .preferredColorScheme(.dark)
    }
}
