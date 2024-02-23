//
//  StarknetTypedData.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import BigInt
import Foundation

public enum StarknetTypedDataError: Error {
    case decodingError
    case dependencyNotDefined(String)
    case invalidShortString
    case encodingError
}

/// Sign message for off-chain usage. Follows standard proposed [here](https://github.com/argentlabs/argent-x/discussions/14)
///
/// ```swift
/// let typedDataString = """
/// {
///     "types": {
///         "StarkNetDomain": [
///             {"name": "name", "type": "felt"},
///             {"name": "version", "type": "felt"},
///             {"name": "chainId", "type": "felt"},
///         ],
///         "Person": [
///             {"name": "name", "type": "felt"},
///             {"name": "wallet", "type": "felt"},
///         ],
///         "Mail": [
///             {"name": "from", "type": "Person"},
///             {"name": "to", "type": "Person"},
///             {"name": "contents", "type": "felt"},
///         ],
///     },
///     "primaryType": "Mail",
///     "domain": {"name": "StarkNet Mail", "version": "1", "chainId": 1},
///     "message": {
///         "from": {
///             "name": "Cow",
///             "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
///         },
///         "to": {
///             "name": "Bob",
///             "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
///         },
///         "contents": "Hello, Bob!",
///     },
/// }
/// """
///
/// let typedData = try JSONDecoder.decode(StarknetTypedData.self, from: typedDataString.data(using: .utf8)!)
///
/// let messageHash = try typedData.getMessageHash(accountAddress: "0x1234")
/// ```
public struct StarknetTypedData: Codable, Equatable, Hashable {
    public let types: [String: [TypeDeclaration]]
    public let primaryType: String
    public let domain: [String: Element]
    public let message: [String: Element]

    private init?(types: [String: [TypeDeclaration]], primaryType: String, domain: [String: Element], message: [String: Element]) {
        let reservedTypeNames = ["felt", "felt*", "string", "selector"]
        for typeName in reservedTypeNames {
            if types.keys.contains(typeName) {
                return nil
            }
        }

        self.types = types
        self.primaryType = primaryType
        self.domain = domain
        self.message = message
    }

    public init?(types: [String: [TypeDeclaration]], primaryType: String, domain: String, message _: String) {
        guard let domainData = domain.data(using: .utf8), let messageData = domain.data(using: .utf8) else {
            return nil
        }

        guard let domain = try? JSONDecoder().decode([String: Element].self, from: domainData),
              let message = try? JSONDecoder().decode([String: Element].self, from: messageData)
        else {
            return nil
        }

        self.init(types: types, primaryType: primaryType, domain: domain, message: message)
    }

    private func getDependencies(of type: String) -> [String] {
        var dependencies = [type]
        var toVisit = [type]

        while !toVisit.isEmpty {
            let currentType = toVisit.removeFirst()
            let params = types[currentType] ?? []

            params.forEach { param in
                let typeStripped = param.type.strippingPointer()

                if types.keys.contains(typeStripped), !dependencies.contains(typeStripped) {
                    dependencies.append(typeStripped)
                    toVisit.append(typeStripped)
                }
            }
        }

        let sorted = dependencies.suffix(from: 1).sorted()

        return [dependencies[0]] + Array(sorted)
    }

    private func encode(dependency: String) throws -> String {
        guard let params = types[dependency] else {
            throw StarknetTypedDataError.dependencyNotDefined(dependency)
        }

        let encodedParams = params.map {
            "\($0.name):\($0.type)"
        }.joined(separator: ",")

        return "\(dependency)(\(encodedParams))"
    }

    private func encode(type: String) throws -> String {
        let dependencies = getDependencies(of: type)

        return try dependencies.map {
            try encode(dependency: $0)
        }.joined()
    }

    private func encode(element: Element, forType typeName: String) throws -> Felt {
        if types.keys.contains(typeName) {
            let object = try unwrapObject(from: element)

            return try getStructHash(typeName: typeName, data: object)
        }

        if types.keys.contains(typeName.strippingPointer()) {
            let array = try unwrapArray(from: element)

            let hashes = try array.map {
                let object = try unwrapObject(from: $0)

                return try getStructHash(typeName: typeName.strippingPointer(), data: object)
            }

            let hash = StarknetCurve.pedersenOn(hashes)

            return hash
        }

        switch typeName {
        case "felt*":
            let array = try unwrapArray(from: element)
            let hashes = try array.map {
                try unwrapFelt(from: $0)
            }
            let hash = StarknetCurve.pedersenOn(hashes)
            return hash
        case "felt", "string":
            return try unwrapFelt(from: element)
        case "selector":
            return try unwrapSelector(from: element)
        default:
            throw StarknetTypedDataError.decodingError
        }
    }

    private func encode(data: [String: Element], forType typeName: String) throws -> [Felt] {
        var values: [Felt] = []

        guard let types = types[typeName] else {
            throw StarknetTypedDataError.encodingError
        }

        try types.forEach { param in
            guard let element = data[param.name] else {
                throw StarknetTypedDataError.encodingError
            }

            let encodedElement = try encode(element: element, forType: param.type)
            values.append(encodedElement)
        }

        return values
    }

    public func getTypeHash(typeName: String) throws -> Felt {
        try starknetSelector(from: encode(type: typeName))
    }

    public func getStructHash(typeName: String, data: [String: Element]) throws -> Felt {
        let encodedData = try encode(data: data, forType: typeName)

        return try StarknetCurve.pedersenOn([getTypeHash(typeName: typeName)] + encodedData)
    }

    public func getStructHash(typeName: String, data: String) throws -> Felt {
        guard let data = data.data(using: .utf8) else {
            throw StarknetTypedDataError.decodingError
        }

        guard let dataDecoded = try? JSONDecoder().decode([String: Element].self, from: data) else {
            throw StarknetTypedDataError.decodingError
        }

        return try getStructHash(typeName: typeName, data: dataDecoded)
    }

    public func getMessageHash(accountAddress: Felt) throws -> Felt {
        try StarknetCurve.pedersenOn(
            Felt.fromShortString("StarkNet Message")!,
            getStructHash(typeName: "StarkNetDomain", data: domain),
            accountAddress,
            getStructHash(typeName: primaryType, data: message)
        )
    }
}

public extension StarknetTypedData {
    struct TypeDeclaration: Codable, Equatable, Hashable {
        public let name: String
        public let type: String

        public init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }

    enum Element: Codable, Hashable, Equatable {
        case object([String: Element])
        case array([Element])
        case string(String)
        case felt(Felt)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let object = try? container.decode([String: Element].self) {
                self = .object(object)
            } else if let array = try? container.decode([Element].self) {
                self = .array(array)
            } else if let felt = try? container.decode(Felt.self) {
                self = .felt(felt)
            } else if let uint = try? container.decode(UInt64.self),
                      let felt = Felt(uint)
            {
                self = .felt(felt)
            } else if let string = try? container.decode(String.self) {
                if let uint = BigUInt(string),
                   let felt = Felt(uint)
                {
                    self = .felt(felt)
                } else {
                    self = .string(string)
                }
            } else {
                throw StarknetTypedDataError.decodingError
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
}

private extension StarknetTypedData {
    func unwrapArray(from element: Element) throws -> [Element] {
        guard case let .array(array) = element else {
            throw StarknetTypedDataError.decodingError
        }

        return array
    }

    func unwrapObject(from element: Element) throws -> [String: Element] {
        guard case let .object(object) = element else {
            throw StarknetTypedDataError.decodingError
        }

        return object
    }

    func unwrapFelt(from element: Element) throws -> Felt {
        switch element {
        case let .felt(felt):
            return felt
        case let .string(string):
            guard let felt = Felt.fromShortString(string) else {
                throw StarknetTypedDataError.decodingError
            }
            return felt
        default:
            throw StarknetTypedDataError.decodingError
        }
    }

    func unwrapSelector(from element: Element) throws -> Felt {
        switch element {
        case let .felt(felt):
            return felt
        case let .string(string):
            return starknetSelector(from: string)
        default:
            throw StarknetTypedDataError.decodingError
        }
    }
}

private extension String {
    func strippingPointer() -> String {
        if self.count == 0 {
            return self
        }

        if self.last == "*" {
            return String(self.dropLast(1))
        }

        return self
    }
}
