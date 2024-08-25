//
//  SettingsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingDeleteSeedConfirmation = false
    @State private var showingShowSeedConfirmation = false
    @State private var isSeedPresented = false
    
    var body: some View {
        NavigationStack {
            Form {
                networkSection
                biometricAuthenticationSection
                dangerZoneSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.getNetwork()
                viewModel.getEsploraUrl()
            }
            .sheet(isPresented: $isSeedPresented) {
                SeedView(viewModel: .init())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .alert(isPresented: $viewModel.showingSettingsViewErrorAlert) {
                Alert(
                    title: Text("Settings Error"),
                    message: Text(viewModel.settingsError?.description ?? "Unknown"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.settingsError = nil
                    }
                )
            }
        }
    }
    
    private var networkSection: some View {
        Section(header: Text("Network")
            .font(.headline)
            .foregroundColor(.bitcoinOrange)) {
                if let network = viewModel.network, let url = viewModel.esploraURL {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(network.uppercased())
                            .font(.title2)
                            .foregroundColor(.bitcoinOrange)
                        Text(
                            url.replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } else {
                    HStack {
                        Text("No Network")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
    }
    
    private var biometricAuthenticationSection: some View {
        Section(header: Text("Biometric Authentication")
            .font(.headline)
            .foregroundColor(.bitcoinOrange)) {
            Toggle("Enable Biometric Authentication", isOn: $viewModel.isBiometricEnabled)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                .onChange(of: viewModel.isBiometricEnabled) { _, isBiometricEnabled in
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                .animation(.easeInOut, value: viewModel.isBiometricEnabled)
        }
    }
    
    private var dangerZoneSection: some View {
        Section(header: Text("Danger Zone")
            .font(.headline)
            .foregroundColor(.red)) {
                
                Button {
                    showingShowSeedConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "eye")
                        Text("Show Seed")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .alert(
                    "Are you sure you want to view the seed?",
                    isPresented: $showingShowSeedConfirmation
                ) {
                    Button("Yes", role: .destructive) {
                        isSeedPresented = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    Button("No", role: .cancel) {}
                }
                
                Button {
                    showingDeleteSeedConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Seed")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .alert(
                    "Are you sure you want to delete the seed?",
                    isPresented: $showingDeleteSeedConfirmation
                ) {
                    Button("Yes", role: .destructive) {
                        viewModel.delete()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    Button("No", role: .cancel) {}
                }
            }
    }
}

// Debug previews for SwiftUI canvas and live previews
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView(viewModel: .init())
            SettingsView(viewModel: .init())
                .environment(\.sizeCategory, .accessibilityLarge)
        }
    }
}
#endif
