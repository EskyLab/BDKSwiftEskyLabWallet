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
                        HStack(spacing: 15) {
                            Image(systemName: "bitcoinsign")
                                .font(.title2) // Slim Bitcoin symbol
                                .foregroundColor(.primary) // Slightly muted color for Bitcoin symbol
                            Text(viewModel.balanceTotal == 0 ? "0" : viewModel.balanceTotal.formattedSatoshis())
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .foregroundColor(viewModel.balanceTotal == 0 ? .secondary : .primary) // Display zero normally
                                .contentTransition(.numericText())
                            Text("sats")
                                .foregroundColor(.secondary)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        
                        // Sync state and price
                        HStack {
                            if viewModel.walletSyncState == .syncing {
                                Image(systemName: "chart.bar.fill")
                                    .symbolEffect(.pulse.byLayer)
                                    .foregroundColor(.bitcoinOrange)
                            }
                            Text(viewModel.satsPrice)
                                .font(.title3.weight(.medium))
                                .foregroundColor(.primary)
                                .contentTransition(.numericText())
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 40.0)
                    .padding(.bottom, 20.0)

                    // Activity section
                    VStack {
                        HStack {
                            Text("Activity")
                                .fontWeight(.bold)
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 5) {
                                if viewModel.walletSyncState == .syncing {
                                    Image(systemName: "slowmo")
                                        .symbolEffect(.pulse.byLayer)
                                        .foregroundColor(.bitcoinOrange)
                                } else if viewModel.walletSyncState == .synced {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .font(.caption)
                        }
                        .padding(.bottom, 10)
                        
                        // Transaction list
                        WalletTransactionListView(
                            transactionDetails: viewModel.transactionDetails,
                            walletSyncState: viewModel.walletSyncState
                        )
                        .refreshable {
                            await viewModel.sync()
                            viewModel.getBalance()
                            viewModel.getTransactions()
                            await viewModel.getPrices()
                        }
                        Spacer()
                    }
                }
                .padding()
                .onReceive(
                    NotificationCenter.default.publisher(for: Notification.Name("TransactionSent")),
                    perform: { _ in
                        newTransactionSent = true
                    }
                )
                .task {
                    if isFirstAppear || newTransactionSent {
                        await viewModel.sync()
                        isFirstAppear = false
                        newTransactionSent = false
                    }
                    viewModel.getBalance()
                    viewModel.getTransactions()
                    await viewModel.getPrices()
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
}

#if DEBUG
    #Preview("WalletView - en") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
    }

    #Preview("WalletView - en - Large") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
            .environment(\.sizeCategory, .accessibilityLarge)
    }

    #Preview("WalletView Zero - en") {
        WalletView(viewModel: .init(priceClient: .mockZero, bdkClient: .mockZero))
    }

    #Preview("WalletView Wait - en") {
        WalletView(viewModel: .init(priceClient: .mockPause, bdkClient: .mock))
    }

    #Preview("WalletView - fr") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
            .environment(\.locale, .init(identifier: "fr"))
    }
#endif
