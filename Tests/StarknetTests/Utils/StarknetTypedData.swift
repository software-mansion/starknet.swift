//
//  StarknetTypedData.swift
//
//
//  Created by Bartosz Rybarski on 15/02/2023.
//

import Foundation
import Starknet

func loadTypedDataFromFile(name: String) throws -> StarknetTypedData {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
          let contents = try? String(contentsOf: url),
          let contentsData = contents.data(using: .utf8)
    else {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to load typed data from file \(name)"))
    }

    return try JSONDecoder().decode(StarknetTypedData.self, from: contentsData)
}
