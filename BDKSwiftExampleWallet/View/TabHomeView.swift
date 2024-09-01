//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {
    @ObservedObject var viewModel: TabHomeViewModel
    @State private var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Haptic feedback generator

    var body: some View {
        ZStack {
            // Background color using the improved background view
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
                customizeTabBarAppearance()
                impactFeedbackGenerator.prepare() // Prepare the feedback generator
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

    // Custom function to adjust the Tab Bar appearance for iOS 15+
    private func customizeTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "bitcoinOrange") // Set Bitcoin orange for selected tab
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    TabHomeView(viewModel: TabHomeViewModel())
}

#Preview {
    TabHomeView(viewModel: TabHomeViewModel())
        .environment(\.sizeCategory, .accessibilityLarge)
}
