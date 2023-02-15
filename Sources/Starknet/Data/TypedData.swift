//
//  TypedData.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import BigInt
import Foundation

enum TypedDataError: Error {
    case decodingError
    case dependencyNotDefined(String)
    case invalidShortString
    case encodingError
}

public struct TypedData: Codable {
    public let types: [String: [TypeDeclaration]]
    public let primaryType: String
    public let domain: [String: Element]
    public let message: [String: Element]

    private init?(types: [String: [TypeDeclaration]], primaryType: String, domain: [String: Element], message: [String: Element]) {
        if types.keys.contains("felt") || types.keys.contains("felt*") {
            return nil
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
            throw TypedDataError.dependencyNotDefined(dependency)
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

    private func encode(element: Element, forType typeName: String) throws -> (String, Felt) {
        if types.keys.contains(typeName) {
            let object = try unwrapObject(from: element)

            return (typeName, try getStructHash(typeName: typeName, data: object))
        }

        if types.keys.contains(typeName.strippingPointer()) {
            let array = try unwrapArray(from: element)

            let hashes = try array.map {
                let object = try unwrapObject(from: $0)

                return try getStructHash(typeName: typeName.strippingPointer(), data: object)
            }

            let hash = StarknetCurve.pedersenOn(hashes)

            return (typeName, hash)
        }

        if typeName == "felt*" {
            let array = try unwrapArray(from: element)

            let hashes = try array.map {
                try unwrapFelt(from: $0)
            }

            let hash = StarknetCurve.pedersenOn(hashes)

            return (typeName, hash)
        }

        if typeName == "felt" {
            return (typeName, try unwrapFelt(from: element))
        }

        throw TypedDataError.decodingError
    }

    private func encode(data: [String: Element], forType typeName: String) throws -> [Felt] {
        var values: [Felt] = []

        guard let types = types[typeName] else {
            throw TypedDataError.encodingError
        }

        try types.forEach { param in
            guard let element = data[param.name] else {
                throw TypedDataError.encodingError
            }

            let (_, encodedValue) = try encode(element: element, forType: param.type)
            values.append(encodedValue)
        }

        return values
    }

    public func getTypeHash(typeName: String) throws -> Felt {
        starknetSelector(from: try encode(type: typeName))
    }

    public func getStructHash(typeName: String, data: [String: Element]) throws -> Felt {
        let encodedData = try encode(data: data, forType: typeName)

        print("Type hash: \(try getTypeHash(typeName: typeName))")

        return StarknetCurve.pedersenOn([try getTypeHash(typeName: typeName)] + encodedData)
    }

    public func getStructHash(typeName: String, data: String) throws -> Felt {
        guard let data = data.data(using: .utf8) else {
            throw TypedDataError.decodingError
        }

        guard let dataDecoded = try? JSONDecoder().decode([String: Element].self, from: data) else {
            throw TypedDataError.decodingError
        }

        return try getStructHash(typeName: typeName, data: dataDecoded)
    }

    public func getMessageHash(accountAddress: Felt) throws -> Felt {
        StarknetCurve.pedersenOn(
            Felt.fromShortString("StarkNet Message")!,
            try getStructHash(typeName: "StarkNetDomain", data: domain),
            accountAddress,
            try getStructHash(typeName: primaryType, data: message)
        )
    }
}

public extension TypedData {
    struct TypeDeclaration: Codable {
        public let name: String
        public let type: String

        public init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }

    enum Element: Codable {
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
}

private extension TypedData {
    func unwrapArray(from element: Element) throws -> [Element] {
        guard case let .array(array) = element else {
            throw TypedDataError.decodingError
        }

        return array
    }

    func unwrapObject(from element: Element) throws -> [String: Element] {
        guard case let .object(object) = element else {
            throw TypedDataError.decodingError
        }

        return object
    }

    func unwrapFelt(from element: Element) throws -> Felt {
        switch element {
        case let .felt(felt):
            return felt
        case let .string(string):
            guard let felt = Felt.fromShortString(string) else {
                throw TypedDataError.decodingError
            }
            return felt
        default:
            throw TypedDataError.decodingError
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
