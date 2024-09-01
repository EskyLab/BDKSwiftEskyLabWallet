//
//  TabHomeView.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 01/09/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import SwiftUI

struct TabHomeView: View {
    @StateObject var viewModel: TabHomeViewModel
    @State private var impactFeedbackGenerator: UIImpactFeedbackGenerator? // Define here

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()

            TabView {
                WalletView(viewModel: WalletViewModel())
                    .tabItem {
                        Label("Wallet", systemImage: "bitcoinsign")
                    }

                ReceiveView(viewModel: ReceiveViewModel())
                    .tabItem {
                        Label("Receive", systemImage: "arrow.down")
                    }

                AmountView(viewModel: AmountViewModel())
                    .tabItem {
                        Label("Amount", systemImage: "arrow.up")
                    }

                SettingsView(viewModel: SettingsViewModel())
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .tint(Color("bitcoinOrange")) // Change to Bitcoin orange
            .onAppear {
                viewModel.loadWallet()
                prepareHapticFeedback() // Prepare haptic feedback when view appears
            }
        }
        .alert(isPresented: $viewModel.showingTabViewErrorAlert) {
            Alert(
                title: Text("TabView Error"),
                message: Text(viewModel.tabViewError?.description ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    viewModel.tabViewError = nil
                }
            )
        }
    }

    // Custom function to prepare the haptic feedback generator
    private func prepareHapticFeedback() {
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator?.prepare()
    }
}

#if DEBUG
#Preview {
    TabHomeView(viewModel: TabHomeViewModel())
}

#Preview {
    TabHomeView(viewModel: TabHomeViewModel())
        .environment(\.sizeCategory, .accessibilityLarge)
}
#endif
