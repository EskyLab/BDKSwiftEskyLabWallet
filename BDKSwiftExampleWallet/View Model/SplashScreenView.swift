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
    @State private var isAnimating = false
    @State private var showCulture = false

    var body: some View {
        ZStack {
            // Dynamically adapt background color based on system appearance
            Color(UIColor.systemBackground) // Automatically adjusts for light and dark mode
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo with fade-in effect
                Image("bitcoin-btc-logo-2") // Your app's logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Adjust size for visibility
                    .scaleEffect(isAnimating ? 1.0 : 0.8) // Scale animation
                    .opacity(isAnimating ? 1.0 : 0.0) // Fade-in effect
                    .animation(.easeIn(duration: 1.0), value: isAnimating) // Animation for logo
                
                // App Name with fade-in effect
                Text("CYPHERPUNK")
                    .font(.custom("SFProDisplay-Black", size: 40)) // Extra bold font
                    .foregroundColor(.primary) // Primary color for text
                    .padding(.top, 16) // Spacing from the logo
                    .opacity(isAnimating ? 1.0 : 0.0) // Fade-in effect
                    .animation(.easeIn(duration: 2.0).delay(0.5), value: isAnimating) // Animation for app name
                
                // Culture Text without animation
                if showCulture {
                    Text("CULTURE")
                        .font(.custom("SFProDisplay-Black", size: 40)) // Extra bold font
                        .foregroundColor(.primary) // Primary color for text
                        .padding(.top, 8) // Spacing from the above text
                        .opacity(showCulture ? 1.0 : 0.0) // Fade-in effect
                        .animation(.easeInOut(duration: 0.8), value: showCulture) // Animation for culture text
                }

                Spacer()

                // Additional white space
                Spacer().frame(height: 60) // Adds extra space at the bottom
            }
            .frame(maxWidth: .infinity) // Ensures VStack takes full width for centering
            .padding(.horizontal) // Padding for horizontal spacing
        }
        .onAppear {
            isAnimating = true // Trigger animations when the view appears
            
            // Show "CULTURE" after "CYPHERPUNK" animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCulture = true
                }
            }
            
            // Simulate a delay before transitioning to the next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isShowingSplash: .constant(true))
            .preferredColorScheme(.light) // Preview in light mode
        SplashScreenView(isShowingSplash: .constant(true))
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}
