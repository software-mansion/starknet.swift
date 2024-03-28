//
//  StarknetTypedData.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import BigInt
import Foundation

public enum StarknetTypedDataError: Error, Equatable {
    case decodingError
    case invalidRevision
    case basicTypeRedefinition
    case invalidTypeName
    case domainNotDefined
    case dependencyNotDefined(String)
    case contextNotDefined
    case parentNotDefined
    case keyNotDefined
    case invalidMerkleTree
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
    public let types: [String: [TypeDeclarationWrapper]]
    public let primaryType: String
    public let domain: Domain
    public let message: [String: Element]

    var revision: Revision {
        try! domain.resolveRevision()
    }

    var hashMethod: StarknetHashMethod {
        switch revision {
        case .v0: return StarknetHashMethod.pedersen
        case .v1: return StarknetHashMethod.poseidon
        }
    }

    func hash(_ array: [Felt]) -> Felt {
        hashMethod.hash(values: array)
    }

    private init(types: [String: [any TypeDeclaration]], primaryType: String, domain: Domain, message: [String: Element]) throws {
        self.types = types.mapValues { value in
            value.map { TypeDeclarationWrapper($0) }
        }
        self.primaryType = primaryType
        self.domain = domain
        self.message = message

        try self.verifyTypes()
    }

    public init(types: [String: [any TypeDeclaration]], primaryType: String, domain: String, message _: String) throws {
        guard let domainData = domain.data(using: .utf8), let messageData = domain.data(using: .utf8) else {
            throw StarknetTypedDataError.decodingError
        }

        guard let domain = try? JSONDecoder().decode(Domain.self, from: domainData),
              let message = try? JSONDecoder().decode([String: Element].self, from: messageData)
        else {
            throw StarknetTypedDataError.decodingError
        }

        try self.init(types: types, primaryType: primaryType, domain: domain, message: message)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let types = try container.decode([String: [TypeDeclarationWrapper]].self, forKey: .types)
        let primaryType = try container.decode(String.self, forKey: .primaryType)
        let domain = try container.decode(Domain.self, forKey: .domain)
        let message = try container.decode([String: Element].self, forKey: .message)

        try self.init(types: types.mapValues { $0.map(\.type) }, primaryType: primaryType, domain: domain, message: message)
    }

    private func verifyTypes() throws {
        guard types.keys.contains(domain.separatorName) else {
            throw StarknetTypedDataError.domainNotDefined
        }

        let reservedTypeNames = ["felt", "string", "selector", "merkletree"]
        for typeName in reservedTypeNames {
            guard !types.keys.contains(typeName) else {
                throw StarknetTypedDataError.basicTypeRedefinition
            }
        }

        try self.types.keys.forEach { typeName in
            guard !typeName.isEmpty else {
                throw StarknetTypedDataError.invalidTypeName
            }
            guard !typeName.isArray() else {
                throw StarknetTypedDataError.invalidTypeName
            }
        }
    }

    private func getDependencies(of type: String) -> [String] {
        var dependencies = [type]
        var toVisit = [type]

        while !toVisit.isEmpty {
            let currentType = toVisit.removeFirst()
            let params = types[currentType] ?? []

            params.forEach { param in
                let typeStripped = param.type.type.strippingPointer()

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
        func escape(_ string: String) -> String {
            switch revision {
            case .v0: string
            case .v1: "\"\(string)\""
            }
        }

        let encodedParams = params.map {
            "\(escape($0.type.name)):\(escape($0.type.type))"
        }.joined(separator: ",")

        return "\(escape(dependency))(\(encodedParams))"
    }

    private func encode(type: String) throws -> String {
        let dependencies = getDependencies(of: type)

        return try dependencies.map {
            try encode(dependency: $0)
        }.joined()
    }

    private func encode(element: Element, forType typeName: String, context: Context? = nil) throws -> Felt {
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

            let hash = hash(hashes)

            return hash
        }

        switch (typeName, revision) {
        case ("felt*", _):
            let array = try unwrapArray(from: element)
            let hashes = try array.map {
                try unwrapFelt(from: $0)
            }
            return hash(hashes)
        case ("felt", _):
            return try unwrapFelt(from: element)
        case ("string", .v0):
            return try unwrapFelt(from: element)
        case ("string", .v1):
            fatalError("This function is not yet implemented")
        case ("shortstring", .v1):
            return try unwrapFelt(from: element)
        case ("selector", _):
            return try unwrapSelector(from: element)
        case ("merkletree", _):
            guard let context else {
                throw StarknetTypedDataError.contextNotDefined
            }
            return try prepareMerkleTreeRoot(from: element, context: context)
        default:
            throw StarknetTypedDataError.dependencyNotDefined(typeName)
        }
    }

    private func encode(data: [String: Element], forType typeName: String) throws -> [Felt] {
        var values: [Felt] = []

        guard let types = types[typeName] else {
            throw StarknetTypedDataError.encodingError
        }

        try types.forEach { param in
            guard let element = data[param.type.name] else {
                throw StarknetTypedDataError.encodingError
            }

            let encodedElement = try encode(element: element, forType: param.type.type, context: Context(parent: typeName, key: param.type.name))
            values.append(encodedElement)
        }

        return values
    }

    public func getTypeHash(typeName: String) throws -> Felt {
        try starknetSelector(from: encode(type: typeName))
    }

    public func getStructHash(typeName: String, data: [String: Element]) throws -> Felt {
        let encodedData = try encode(data: data, forType: typeName)

        return try hash([getTypeHash(typeName: typeName)] + encodedData)
    }

    private func getStructHash(typeName: String, data: Data) throws -> Felt {
        guard let decodedData = try? JSONDecoder().decode([String: Element].self, from: data) else {
            throw StarknetTypedDataError.decodingError
        }

        return try getStructHash(typeName: typeName, data: decodedData)
    }

    public func getStructHash(typeName: String, data: String) throws -> Felt {
        guard let data = data.data(using: .utf8) else {
            throw StarknetTypedDataError.decodingError
        }

        return try getStructHash(typeName: typeName, data: data)
    }

    public func getStructHash(domain: Domain) throws -> Felt {
        guard let domainData = try? JSONEncoder().encode(domain) else {
            throw StarknetTypedDataError.encodingError
        }
        return try getStructHash(typeName: domain.separatorName, data: domainData)
    }

    public func getMessageHash(accountAddress: Felt) throws -> Felt {
        try hash([
            Felt.fromShortString("StarkNet Message")!,
            getStructHash(domain: domain),
            accountAddress,
            getStructHash(typeName: primaryType, data: message),
        ])
    }
}

public extension StarknetTypedData {
    struct Domain: Codable, Equatable, Hashable {
        public let name: Element
        public let version: Element
        public let chainId: Element
        public let revision: Element?

        public func resolveRevision() throws -> Revision {
            guard let revision else {
                return .v0
            }
            switch revision {
            case let .felt(felt):
                guard let revision = Revision(rawValue: felt) else {
                    throw StarknetTypedDataError.invalidRevision
                }
                return revision
            default:
                throw StarknetTypedDataError.invalidRevision
            }
        }

        public var separatorName: String {
            switch try! resolveRevision() {
            case .v0: "StarkNetDomain"
            case .v1: "StarknetDomain"
            }
        }
    }

    enum Revision: Felt, Codable, Equatable {
        case v0 = 0
        case v1 = 1
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
    struct Context: Equatable {
        let parent: String
        let key: String
    }

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

    func prepareMerkleTreeRoot(from element: Element, context: Context) throws -> Felt {
        let leavesType = try getMerkleTreeLeavesType(context: context)

        let elements = try unwrapArray(from: element)
        let structHashes = try elements.map { element in
            try encode(element: element, forType: leavesType)
        }

        guard let merkleTree = MerkleTree(leafHashes: structHashes, hashMethod: hashMethod) else {
            throw StarknetTypedDataError.invalidMerkleTree
        }

        return merkleTree.rootHash
    }

    func getMerkleTreeLeavesType(context: Context) throws -> String {
        let (parent, key) = (context.parent, context.key)

        guard let parentType = types[parent] else {
            throw StarknetTypedDataError.parentNotDefined
        }
        guard let targetType = parentType.first(where: { $0.type.name == key }) else {
            throw StarknetTypedDataError.keyNotDefined
        }
        guard let merkleType = targetType.type as? MerkleTreeType else {
            throw StarknetTypedDataError.decodingError
        }

        return merkleType.contains
    }
}

private extension String {
    func strippingPointer() -> String {
        if self.isArray() {
            return String(self.dropLast(1))
        }

        return self
    }

    func isArray() -> Bool {
        self.hasSuffix("*")
    }
}
