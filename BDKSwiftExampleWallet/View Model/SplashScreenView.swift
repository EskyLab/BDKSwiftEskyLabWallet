//
//  SplashScreenView.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 22/08/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isShowingSplash: Bool

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground) // Background color or image
                .ignoresSafeArea()

            VStack {
                Spacer() // Pushes content down to center vertically
                
                // Logo
                Image("bitcoin-btc-logo-2") // Custom logo image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Adjust size for visibility
                    .padding(.bottom, 20) // Add padding below the logo
                
                // App Name
                VStack(spacing: 8) {
                    Text("CYPHERPUNK")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary) // Primary color for text
                    
                    Text("CULTURE")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary) // Primary color for text
                }
                .padding(.bottom, 40) // Spacing between text and bottom white space
                
                Spacer() // Pushes content up to center vertically
                
                // Additional white space
                Spacer().frame(height: 60) // Adds extra space at the bottom
            }
            .frame(maxWidth: .infinity) // Ensures VStack takes full width for centering
            .padding(.horizontal) // Padding for horizontal spacing
        }
        .onAppear {
            // Simulate a delay before transitioning to the next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isShowingSplash = false
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isShowingSplash: .constant(true))
    }
}
