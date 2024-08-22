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
            Color.white.ignoresSafeArea() // Background color or image
            VStack {
                // Add your promotional content here
                Image("YourAppLogo") // Replace with your app's logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("Welcome to MyApp!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Optional: Add more promotional content or animations here
            }
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
