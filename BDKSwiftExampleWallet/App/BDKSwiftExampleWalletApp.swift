//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI

@main
struct BDKSwiftExampleWalletApp: App {

    init() {
        customizeGlobalTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            TabHomeView(viewModel: TabHomeViewModel()) // Reference TabHomeView here
        }
    }

    private func customizeGlobalTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "bitcoinOrange")
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
