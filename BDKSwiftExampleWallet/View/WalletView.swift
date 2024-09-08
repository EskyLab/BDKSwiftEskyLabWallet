//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import BitcoinDevKit
import Promises

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var isRefreshing = false
    @State private var showSyncOverlay = false
    @State private var isSyncing: Bool = false
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled: Bool = false
    @AppStorage("hasShownWelcomeMessage") private var hasShownWelcomeMessage: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                mainWalletView

                if showSyncOverlay {
                    overlayView
                }
            }
        }
        .alert(isPresented: $viewModel.showingWalletViewErrorAlert) {
            Alert(
                title: Text("Wallet Error"),
                message: Text(viewModel.walletViewError?.localizedDescription ?? "Unknown"),
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
                .fontWidth(.expanded)
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
                        .contentTransition(.numericText())
                    Text("sats")
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)

                Text(viewModel.satsPrice)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.secondary)
                    .contentTransition(.numericText())
            }

            HStack {
                Text("Activity")
                    .fontWeight(.bold)
                    .font(.headline)
                Spacer()
                if viewModel.walletSyncState == .syncing || isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.trailing, 5)
                    Text(activityText)
                        .foregroundColor(.orange)
                        .font(.caption)
                } else if viewModel.walletSyncState == .synced {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Wallet Synced")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .padding(.bottom, 10)

            WalletTransactionListView(
                transactionDetails: viewModel.transactionDetails,
                walletSyncState: viewModel.walletSyncState
            )
            .blur(radius: showSyncOverlay ? 2 : 0)
            .opacity(showSyncOverlay ? 0.5 : 1.0)
            .refreshable {
                isRefreshing = true
                fetchWalletData()
                isRefreshing = false
            }
            Spacer()
        }
        .padding()
        .onAppear {
            if isFirstAppear || newTransactionSent {
                fetchWalletData()
                isFirstAppear = false
            }
        }
    }

    private func fetchWalletData() {
        toggleSyncOverlay(show: true)  // Show overlay immediately when refresh begins
        isRefreshing = true  // Indicate that refreshing is happening

        viewModel.sync()
            .then { _ in
                // Fetch balance, transactions, and prices concurrently
                let balancePromise = self.viewModel.getBalance()
                let transactionPromise = self.viewModel.getTransactions()
                let pricePromise = self.viewModel.getPrices()

                // Update the balance, transaction, and prices as soon as they arrive
                return all(balancePromise, transactionPromise, pricePromise)
            }
            .then { _ -> Promise<Void> in
                // Perform UI updates after data has been fetched
                if self.isFirstAppear && !self.hasShownWelcomeMessage {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.hasShownWelcomeMessage = true
                    }
                }
                return Promise(())
            }
            .catch { error in
                // Handle errors
                if let bdkError = error as? BdkError {
                    self.viewModel.walletViewError = bdkError
                } else {
                    self.viewModel.walletViewError = .Generic(message: "Unknown error occurred.")
                }
                self.viewModel.showingWalletViewErrorAlert = true
            }
            .then {
                // Hide the overlay and end refreshing after everything has completed
                toggleSyncOverlay(show: false)
                isRefreshing = false
            }
    }

    private func toggleSyncOverlay(show: Bool) {
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = show
        }
    }

    private var overlayView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                if viewModel.isSyncing {  // Use viewModel.isSyncing
                    Image(systemName: "arrow.2.circlepath.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.bitcoinOrange)
                    Text(viewModel.activityText)  // Shows the current sync activity
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("This may take a few moments.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    if viewModel.price > 0 {
                        Text("BTC Price: $\(viewModel.price, specifier: "%.2f")")
                            .font(.title2.weight(.medium))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.7).cornerRadius(10))
            .transition(.opacity)
        }
    }

    private var activityText: String {
        if newTransactionSent {
            return "Sending Transaction..."
        } else if viewModel.transactionDetails.contains(where: { $0.sent == 0 && $0.confirmationTime == nil }) {
            return "Receiving Transaction..."
        } else if isRefreshing {
            return "Starting data fetch..."
        } else {
            return "Syncing Wallet..."
        }
    }
}
