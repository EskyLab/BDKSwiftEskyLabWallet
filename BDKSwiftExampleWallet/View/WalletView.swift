//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var isSyncing: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(spacing: 10) {
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
                            if viewModel.walletSyncState == .synced {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.bottom, 10)

                        WalletTransactionListView(
                            transactionDetails: viewModel.transactionDetails,
                            walletSyncState: viewModel.walletSyncState
                        )
                        .refreshable {
                            await refreshData()
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
                    }
                )
                .task {
                    if isFirstAppear || newTransactionSent {
                        isSyncing = true
                        await refreshData()
                        isSyncing = false
                        isFirstAppear = false
                        newTransactionSent = false
                    }
                }

                if isSyncing {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.bitcoinOrange)
                                .symbolEffect(.pulse.byLayer)
                            Text("Syncing...")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7).cornerRadius(10))
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

    private func refreshData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await viewModel.sync()
            }
            group.addTask {
                await viewModel.getBalance()
            }
            group.addTask {
                await viewModel.getTransactions()
            }
            group.addTask {
                await viewModel.getPrices()
            }
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
