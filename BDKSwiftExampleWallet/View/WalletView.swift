//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var isFirstTimeUser = true
    @State private var isRefreshing = false
    @State private var showSyncOverlay = false  // No overlay spinner
    @Environment(\.presentationMode) var presentationMode // For navigating back

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title with animation
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

                    // Balance display
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

                        // US$ price in Satoshis equivalent
                        Text(viewModel.satsPrice)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.secondary)
                            .contentTransition(.numericText())
                    }

                    // Sync state
                    HStack {
                        Text("Activity")
                            .fontWeight(.bold)
                            .font(.headline)
                        Spacer()
                        if viewModel.walletSyncState == .syncing || isRefreshing {
                            ProgressView()  // Keep this spinner
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

                    // Transaction list
                    WalletTransactionListView(
                        transactionDetails: viewModel.transactionDetails,
                        walletSyncState: viewModel.walletSyncState
                    )
                    .blur(radius: showSyncOverlay ? 5 : 0) // Blur effect (if needed)
                    .opacity(showSyncOverlay ? 0.5 : 1.0) // Translucent effect (if needed)
                    .refreshable {
                        isRefreshing = true
                        await performDataFetch() // Trigger data fetch on refresh
                        isRefreshing = false
                    }
                    Spacer()
                }
                .padding()
                .task {
                    if isFirstAppear || newTransactionSent {
                        await performInitialSyncAndFetch()
                        isFirstAppear = false
                        isFirstTimeUser = false // Ensure the welcome message doesn't show again after first sync
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSyncOverlay = false // Hide the overlay with animation after syncing
                        }
                    }
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

    // A method to fetch data when the user pulls down to refresh
    private func performDataFetch() async {
        print("Starting data fetch...")
        await viewModel.sync()
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()
        print("Data fetch completed. Fetched balance: \(viewModel.balanceTotal)")
        print("Fetched transactions: \(viewModel.transactionDetails)")

        // Display block height immediately after fetching transactions
        if let height = viewModel.transactionDetails.first?.confirmationTime?.height {
            print("Block height: \(height)") // Check in console
        } else {
            print("Block height not available.")
        }

        // Ensure the transactions are unblurred and fully visible after the overlay ends
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false // Hide the overlay after refresh completes
        }
    }

    // Existing method for the initial sync and fetch
    private func performInitialSyncAndFetch() async {
        print("Starting initial sync...")
        await viewModel.sync()
        print("Initial sync completed. Fetching balance and transactions.")
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()
        print("Fetched balance: \(viewModel.balanceTotal)")
        print("Fetched transactions: \(viewModel.transactionDetails)")

        // Display block height immediately after fetching transactions
        if let height = viewModel.transactionDetails.first?.confirmationTime?.height {
            print("Block height: \(height)") // Check in console
        } else {
            print("Block height not available.")
        }

        // Ensure the transactions are unblurred and fully visible after the overlay ends
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false // Hide the overlay with animation after syncing
        }
    }
    
    // Determine the appropriate text for the activity view
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
