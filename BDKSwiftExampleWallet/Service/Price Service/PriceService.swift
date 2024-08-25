//
//  PriceService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

private struct PriceService {
    func fetchPrices() async throws -> Price {
        guard let url = URL(string: "https://mempool.space/api/v1/prices") else {
            throw PriceServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PriceServiceError.invalidServerResponse
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Price.self, from: data)
        } catch {
            throw PriceServiceError.serialization
        }
    }
}

struct PriceClient {
    let fetchPrice: () async throws -> Price

    private init(fetchPrice: @escaping () async throws -> Price) {
        self.fetchPrice = fetchPrice
    }
}

extension PriceClient {
    static let live = Self(fetchPrice: { try await PriceService().fetchPrices() })
}

#if DEBUG
extension PriceClient {
    static let mock = Self(fetchPrice: { currentPriceMock })
    static let mockPause = Self(fetchPrice: {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Sleeps for 2 seconds
        return currentPriceMock
    })
    static let mockZero = Self(fetchPrice: { currentPriceMockZero })
}
#endif

// Existing enumeration for clear error handling
// Define your custom error types with a different name
enum NewPriceServiceError: Error {
    case invalidURL
    case invalidServerResponse
}
