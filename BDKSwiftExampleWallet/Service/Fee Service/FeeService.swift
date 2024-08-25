//
//  FeeService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/23/23.
//

import Foundation

private struct FeeService {
    func fetchFees() async throws -> RecommendedFees {
        guard let url = URL(string: "https://mempool.space/api/v1/fees/recommended") else {
            throw FeeServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FeeServiceError.invalidServerResponse
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(RecommendedFees.self, from: data)
        } catch {
            throw FeeServiceError.serialization
        }
    }
}

struct FeeClient {
    let fetchFees: () async throws -> RecommendedFees

    private init(fetchFees: @escaping () async throws -> RecommendedFees) {
        self.fetchFees = fetchFees
    }
}

extension FeeClient {
    static let live = Self(fetchFees: { try await FeeService().fetchFees() })
}

#if DEBUG
extension FeeClient {
    static let mock = Self(fetchFees: { currentFeesMock })
}
#endif
