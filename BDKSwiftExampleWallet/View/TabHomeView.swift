//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {
    @Bindable var viewModel: TabHomeViewModel

    var body: some View {
        ZStack {
            // Background color using the improved background view
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()

            TabView {
                WalletView(viewModel: .init())
                    .tabItem {
                        Label("Wallet", systemImage: "bitcoinsign")
                    }

                ReceiveView(viewModel: .init())
                    .tabItem {
                        Label("Receive", systemImage: "arrow.down")
                    }

                AmountView(viewModel: .init())
                    .tabItem {
                        Label("Amount", systemImage: "arrow.up")
                    }

                SettingsView(viewModel: .init())
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .tint(Color("bitcoinOrange")) // Change to Bitcoin orange
            .onAppear {
                viewModel.loadWallet()
                customizeTabBarAppearance()
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

    // Custom function to adjust the Tab Bar appearance for iOS 18
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
    TabHomeView(viewModel: .init())
}

#Preview {
    TabHomeView(viewModel: .init())
        .environment(\.sizeCategory, .accessibilityLarge)
}
