//
//  SeedView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import SwiftUI
import BitcoinDevKit

struct SeedView: View {
    @ObservedObject var viewModel: SeedViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.seed.mnemonic.isEmpty {
                Text("No seed available.")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mnemonic: \(viewModel.seed.mnemonic)")
                        .font(.body)
                        .foregroundColor(.primary)

                    Text("Descriptor: \(viewModel.seed.descriptor)")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Change Descriptor: \(viewModel.seed.changeDescriptor)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.getSeed()
        }
        .alert(isPresented: $viewModel.showingSeedViewErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.seedViewError?.description ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
#if DEBUG
    #Preview("SeedView - en") {
        SeedView(viewModel: .init())
    }

    #Preview("SeedView - en - Large") {
        SeedView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
