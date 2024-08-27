//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import BitcoinDevKit
import BitcoinUI
import LocalAuthentication

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var isFirstTimeUser = true
    @State private var isRefreshing = false
    @State private var showSyncOverlay = false
    @AppStorage("isBiometricEnabled") private var isBiometricEnabled: Bool = false

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
                await performDataFetch()
                isRefreshing = false
            }
            Spacer()
        }
        .padding()
        .task {
            if isFirstAppear || newTransactionSent {
                await performInitialSyncAndFetch()
                isFirstAppear = false
                isFirstTimeUser = false
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSyncOverlay = false
                }
            }
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

    private var overlayView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                if isFirstTimeUser && !isRefreshing {
                    Image(systemName: "network")
                        .font(.system(size: 40))
                        .foregroundColor(.bitcoinOrange)
                    Text("CypherPunk Culture Bitcoin Wallet!")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Bitcoin: A Peer-to-Peer Electronic Cash System, We're setting up your wallet. This may take a few moments.")
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
                            showSyncOverlay = false
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
                    Text(activityText)
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
