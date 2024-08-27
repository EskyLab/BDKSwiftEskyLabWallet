//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import LocalAuthentication
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var isRefreshing = false
    @State private var showSyncOverlay = false
    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                if isAuthenticated {
                    mainWalletView
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                } else {
                    authenticateUser()
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }

                if showSyncOverlay {
                    syncOverlay
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
        }
        .alert(isPresented: $viewModel.showingWalletViewErrorAlert) {
            Alert(
                title: Text("Wallet Error"),
                message: Text(viewModel.walletViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.walletViewError = nil
                }
            )
        }
    }

    private var mainWalletView: some View {
        VStack(spacing: 20) {
            Text("Bitcoin".uppercased())
                .font(.title2.weight(.bold))
                .foregroundColor(.bitcoinOrange)
                .scaleEffect(isAnimating ? 1.0 : 0.6)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isAnimating = true
                    }
                }

            VStack(spacing: 5) {
                HStack(spacing: 10) {
                    Text(viewModel.balanceTotal == 0 ? "0" : viewModel.balanceTotal.formattedSatoshis())
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.balanceTotal == 0 ? .secondary : .primary)
                    Text("sats")
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)

                Text(viewModel.satsPrice)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.secondary)
            }

            WalletTransactionListView(
                transactionDetails: viewModel.transactionDetails,
                walletSyncState: viewModel.walletSyncState
            )
            .blur(radius: showSyncOverlay ? 2 : 0)
            .opacity(showSyncOverlay ? 0.5 : 1.0)
            .refreshable {
                isRefreshing = true
                await performDataFetch()
                isRefreshing = false
            }
            Spacer()
        }
        .padding()
        .task {
            if isFirstAppear {
                await performInitialSyncAndFetch()
                isFirstAppear = false
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSyncOverlay = false
                }
            }
        }
    }

    private func authenticateUser() -> some View {
        Text("Authenticating...").onAppear {
            authenticateWithBiometrics { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isAuthenticated = true
                    }
                } else {
                    isAuthenticated = true
                }
            }
        }
    }

    private func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }

    private func performDataFetch() async {
        showSyncOverlay = true
        await viewModel.sync()
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()

        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false
        }
    }

    private func performInitialSyncAndFetch() async {
        showSyncOverlay = true
        await viewModel.sync()
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()

        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false
        }
    }

    private var syncOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.bitcoinOrange)
                Text("Syncing Wallet...")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("This may take a few moments.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                // Displaying Bitcoin price in USD
                if viewModel.price > 0 {
                    Text("BTC Price: $\(viewModel.price, specifier: "%.2f")")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.black.opacity(0.7).cornerRadius(10))
            .transition(.opacity)
        }
    }

    private var activityText: String {
        if isRefreshing {
            return "Refreshing Wallet..."
        } else {
            return "Syncing Wallet..."
        }
    }
}
