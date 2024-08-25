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
    @State private var showSyncOverlay = true
    @Environment(\.presentationMode) var presentationMode // For navigating back

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(spacing: 10) {
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
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            // Additional logic if needed when the spinner appears
                                        }
                                    }
                                    .onDisappear {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            // Additional logic if needed when the spinner disappears
                                        }
                                    }
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
                        .refreshable {
                            isRefreshing = true
                            await performDataFetch()
                            isRefreshing = false
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSyncOverlay = true // Show the overlay during refresh
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 40.0)
                    .padding(.bottom, 20.0)
                }
                .padding()
                .onReceive(
                    NotificationCenter.default.publisher(for: Notification.Name("TransactionSent")),
                    perform: { _ in
                        newTransactionSent = true
                        // Delay for a few seconds before returning to the initial tab view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            newTransactionSent = false
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSyncOverlay = false
                            }
                            presentationMode.wrappedValue.dismiss() // Navigate back to the initial view
                        }
                    }
                )
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

                // Overlay for Syncing, Fetching, or Transaction Sent
                if showSyncOverlay && (viewModel.walletSyncState == .syncing || isFirstAppear || newTransactionSent || (isFirstTimeUser && !isRefreshing) || isRefreshing) {
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
                                // Displaying Block Height - brighter and bold
                                if let height = viewModel.transactionDetails.first?.confirmationTime?.height {
                                    Text("Block \(height.delimiter)")
                                        .foregroundColor(.yellow)  // Brighter color
                                        .font(.headline.weight(.bold))  // Bold font
                                } else {
                                    Text("Block height unavailable")
                                        .foregroundColor(.red)
                                        .font(.caption)
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

    // A method to handle syncing and fetching all relevant data
    private func performInitialSyncAndFetch() async {
        print("Starting initial sync...")
        await viewModel.sync()
        print("Initial sync completed. Fetching balance and transactions.")
        viewModel.getBalance()
        viewModel.getTransactions()
        await viewModel.getPrices()
        print("Fetched balance: \(viewModel.balanceTotal)")
        print("Fetched transactions: \(viewModel.transactionDetails)")
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
        withAnimation(.easeInOut(duration: 0.5)) {
            showSyncOverlay = false // Hide the overlay after refresh completes
        }
    }

    // Determine the appropriate text for the activity view
    private var activityText: String {
        if newTransactionSent {
            return "Sending Transaction..."
        } else if isRefreshing {
            return "Fetching data..."
        } else {
            return "Syncing Wallet..."
        }
    }
}
