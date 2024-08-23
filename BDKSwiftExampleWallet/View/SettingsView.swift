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
    @State private var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Haptic feedback generator

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Network")
                    .font(.headline)
                    .foregroundColor(.bitcoinOrange)) {
                    if let network = viewModel.network, let url = viewModel.esploraURL {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(network)".uppercased())
                                .font(.title2)
                                .foregroundColor(.bitcoinOrange)
                            Text(
                                url.replacingOccurrences(
                                    of: "https://",
                                    with: ""
                                ).replacingOccurrences(
                                    of: "http://",
                                    with: ""
                                )
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

                Section(header: Text("Biometric Authentication")
                    .font(.headline)
                    .foregroundColor(.bitcoinOrange)) {
                    // Toggle to enable or disable biometric authentication
                    Toggle("Enable Biometric Authentication", isOn: $viewModel.isBiometricEnabled)
                        .padding()
                        .background(Color(UIColor.systemBackground))  // Background color for the toggle
                        .cornerRadius(8)  // Rounded corners
                        .shadow(radius: 2)  // Shadow for depth
                        .onChange(of: viewModel.isBiometricEnabled) { newValue in
                            // Handle toggle change if needed
                            impactFeedbackGenerator.impactOccurred()
                        }
                        .animation(.easeInOut, value: viewModel.isBiometricEnabled) // Apply animation to toggle change
                }

                Section(header: Text("Danger Zone")
                    .font(.headline)
                    .foregroundColor(.red)) {
                    Button {
                        showingShowSeedConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "eye")  // Eye icon
                            Text("Show Seed")
                                .foregroundColor(.red)  // Red text color for emphasis
                                .fontWeight(.semibold)  // Semi-bold font weight
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))  // Background color for the button
                        .cornerRadius(8)  // Rounded corners
                        .shadow(radius: 2)  // Shadow for depth
                    }
                    .alert(
                        "Are you sure you want to view the seed?",
                        isPresented: $showingShowSeedConfirmation
                    ) {
                        Button("Yes", role: .destructive) {
                            isSeedPresented = true  // Show seed view if confirmed
                            impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback for confirmation
                        }
                        Button("No", role: .cancel) {}  // Cancel action
                    }

                    Button {
                        showingDeleteSeedConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")  // Trash icon
                            Text("Delete Seed")
                                .foregroundColor(.red)  // Red text color for emphasis
                                .fontWeight(.semibold)  // Semi-bold font weight
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))  // Background color for the button
                        .cornerRadius(8)  // Rounded corners
                        .shadow(radius: 2)  // Shadow for depth
                    }
                    .alert(
                        "Are you sure you want to delete the seed?",
                        isPresented: $showingDeleteSeedConfirmation
                    ) {
                        Button("Yes", role: .destructive) {
                            viewModel.delete()  // Call delete method on confirmation
                            impactFeedbackGenerator.impactOccurred() // Trigger haptic feedback for delete
                        }
                        Button("No", role: .cancel) {}  // Cancel action
                    }
                }
            }
            .navigationTitle("Settings")  // Title of the navigation bar
            .navigationBarTitleDisplayMode(.large)  // Display mode for the navigation title
            .onAppear {
                viewModel.getNetwork()  // Fetch network information on appear
                viewModel.getEsploraUrl()  // Fetch Esplora URL on appear
            }
            .sheet(
                isPresented: $isSeedPresented
            ) {
                SeedView(viewModel: .init())  // Present SeedView as a sheet
                    .presentationDetents([.medium, .large])  // Allow different sheet sizes
                    .presentationDragIndicator(.visible)  // Show drag indicator
            }
            .alert(isPresented: $viewModel.showingSettingsViewErrorAlert) {
                Alert(
                    title: Text("Settings Error"),  // Title of the alert
                    message: Text(viewModel.settingsError?.description ?? "Unknown"),  // Error message
                    dismissButton: .default(Text("OK")) {  // Default button to dismiss alert
                        viewModel.settingsError = nil  // Clear error after dismissal
                    }
                )
            }
        }
    }
}

// Debug previews for SwiftUI canvas and live previews
#if DEBUG
    #Preview {
        SettingsView(viewModel: .init())  // Initialize SettingsView with a mock viewModel
    }

    #Preview {
        SettingsView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)  // Preview with larger text for accessibility
    }
#endif
