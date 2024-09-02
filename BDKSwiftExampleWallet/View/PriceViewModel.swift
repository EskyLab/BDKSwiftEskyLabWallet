//
//  PriceViewModel.swift
//  CypherPunkCulture
//
//  Created by Esky Lab  on 02/09/2024.
//  Copyright © 2024 CypherPunkCulture. All rights reserved.
//

import Foundation
import Combine

class PriceViewModel: ObservableObject {
    @Published var bitcoinPriceUSD: Double?
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchBitcoinPrice() {
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/BTC.json")!

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: BitcoinPriceResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                }
            } receiveValue: { response in
                self.bitcoinPriceUSD = response.bpi.USD.rateFloat
            }
            .store(in: &cancellables)
    }
}

struct BitcoinPriceResponse: Decodable {
    let bpi: BPI

    struct BPI: Decodable {
        let USD: Currency
    }

    struct Currency: Decodable {
        let rateFloat: Double

        enum CodingKeys: String, CodingKey {
            case rateFloat = "rate_float"
        }
    }
}
