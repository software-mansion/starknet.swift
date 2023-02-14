//
//  TypedData.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import BigInt
import Foundation

public struct TypedDataType: Codable {
    public let name: String
    public let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}

enum TypedDataError: Error {
    case decodingError
}

public enum TDElement: Codable {
    case object([String: TDElement])
    case array([TDElement])
    case string(String)
    case felt(Felt)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let object = try? container.decode([String: TDElement].self) {
            self = .object(object)
        } else if let array = try? container.decode([TDElement].self) {
            self = .array(array)
        } else if let felt = try? container.decode(Felt.self) {
            self = .felt(felt)
        } else if let uint = try? container.decode(UInt64.self),
                  let felt = Felt(uint)
        {
            self = .felt(felt)
        } else if let string = try? container.decode(String.self) {
            if let uint = BigUInt(string), let felt = Felt(uint) {
                self = .felt(felt)
            } else {
                self = .string(string)
            }
        } else {
            throw TypedDataError.decodingError
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(string):
            try string.encode(to: encoder)
        case let .felt(felt):
            try felt.encode(to: encoder)
        case let .object(object):
            try object.encode(to: encoder)
        case let .array(array):
            try array.encode(to: encoder)
        }
    }
}

public struct TypedData: Codable {
    public let types: [String: [TypedDataType]]
    public let primaryType: String
    public let domain: [String: TDElement]
    public let message: [String: TDElement]

    private init(types: [String: [TypedDataType]], primaryType: String, domain: [String: TDElement], message: [String: TDElement]) {
        self.types = types
        self.primaryType = primaryType
        self.domain = domain
        self.message = message
    }

    public init?(types: [String: [TypedDataType]], primaryType: String, domain: String, message _: String) {
        guard let domainData = domain.data(using: .utf8), let messageData = domain.data(using: .utf8) else {
            return nil
        }

        guard let domain = try? JSONDecoder().decode([String: TDElement].self, from: domainData),
              let message = try? JSONDecoder().decode([String: TDElement].self, from: messageData)
        else {
            return nil
        }

        self.init(types: types, primaryType: primaryType, domain: domain, message: message)
    }
}
