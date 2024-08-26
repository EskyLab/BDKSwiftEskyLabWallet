//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI
import LocalAuthentication

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var isFirstTimeUser = true
    @State private var isRefreshing = false
    @State private var showSyncOverlay = false
    @State private var isAuthenticated = false
    @State private var blockHeight: UInt32? = nil // Updated to match your block height type
    @Environment(\.presentationMode) var presentationMode // For navigating back

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                if isAuthenticated {
                    mainWalletView
                } else {
                    authenticateUser()
                }

                // Overlay for Syncing, Fetching, or Transaction Sent
                if showSyncOverlay {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            if isFirstTimeUser && !isRefreshing {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                                Text("Welcome to your new Bitcoin Wallet!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("We're setting up your wallet. This may take a few moments.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Once syncing is complete, your transactions and balance will be displayed here.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                                Button("Got it!") {
                                    isFirstTimeUser = false
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showSyncOverlay = false // Hide overlay with animation
                                    }
                                }
                                .padding(.top, 10)
                                .buttonStyle(.borderedProminent)
                                .tint(.bitcoinOrange)
                            } else {
                                Image(systemName: newTransactionSent ? "paperplane.fill" : "chart.bar.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.bitcoinOrange)
                                    .symbolEffect(.pulse.byLayer)
                                Text(activityText)  // Updated to display appropriate activity
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("This may take a few moments.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                // Displaying Block Height - using the correct method
                                if let height = blockHeight {
                                    Text("Block \(height.delimiter)")
                                        .foregroundColor(.yellow)  // Brighter color
                                        .font(.headline.weight(.bold))  // Bold font
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7).cornerRadius(10))
                        .transition(.opacity) // Smooth opacity transition for overlay
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

    private var mainWalletView: some View {
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

    // Function to handle user authentication
    private func authenticateUser() -> some View {
        Text("Authenticating...").onAppear {
            authenticateWithBiometrics { success in
                if success {
                    // Add a 2-second delay after authentication before showing the wallet view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isAuthenticated = true
                    }
                } else {
                    // If authentication fails or is not available, proceed to the wallet view
                    isAuthenticated = true
                }
            }
        }
    }

    // Function to trigger biometric authentication
    private func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your wallet."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        // Handle authentication failure
                        completion(false)
                    }
                }
            }
        } else {
            // Biometrics not available, proceed without authentication
            completion(false)
        }
    }

    // A method to fetch data when the user pulls down to refresh
    private func performDataFetch() async {
        showSyncOverlay = true
        await viewModel.sync()
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()

        // Display block height immediately after fetching transactions
        if let height = viewModel.transactionDetails.first?.confirmationTime?.height {
            blockHeight = height
            print("Block height: \(height)")
        } else {
            blockHeight = nil
            print("Block height not available.")
        }

        // Ensure the transactions are unblurred and fully visible after the overlay ends
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false
        }
    }

    // Existing method for the initial sync and fetch
    private func performInitialSyncAndFetch() async {
        showSyncOverlay = true
        await viewModel.sync()
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()

        // Display block height immediately after fetching transactions
        if let height = viewModel.transactionDetails.first?.confirmationTime?.height {
            blockHeight = height
            print("Block height: \(height)")
        } else {
            blockHeight = nil
            print("Block height not available.")
        }

        // Ensure the transactions are unblurred and fully visible after the overlay ends
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false
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
