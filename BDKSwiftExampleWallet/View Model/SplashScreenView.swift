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
            Color.bitcoinBlack.ignoresSafeArea() // Background color
            
            VStack {
                Spacer()
                
                // Logo
                Image(systemName: "bitcoinsign.circle.fill") // Temporary SF Symbol as the logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) // Adjust size as needed
                    .padding(.bottom, 20) // Space between logo and text
                
                // Main Text
                Text("CYPHERPUNK CULTURE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white) // Ensure text is visible on dark background
                
                Spacer()
            }
        }
        .onAppear {
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
