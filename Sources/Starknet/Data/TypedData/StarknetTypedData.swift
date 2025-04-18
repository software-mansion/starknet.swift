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
    case invalidRevision(Felt)
    case presetTypeRedefinition(String)
    case basicTypeRedefinition(String)
    case invalidTypeName(String)
    case danglingType(String)
    case unsupportedType(String)
    case dependencyNotDefined(String)
    case contextNotDefined
    case parentNotDefined
    case keyNotDefined
    case invalidNumericValue(StarknetTypedData.Element)
    case invalidBool(StarknetTypedData.Element)
    case invalidMerkleTree
    case invalidShortString
    case encodingError
}

/// Sign message for off-chain usage. Follows standard proposed [here](https://github.com/starknet-io/SNIPs/blob/main/SNIPS/snip-12.md)
///
/// ```swift
/// let typedDataString = """
/// {
///     "types": {
///         "StarknetDomain": [
///             {"name": "name", "type": "shortstring"},
///             {"name": "version", "type": "shortstring"},
///             {"name": "chainId", "type": "shortstring"},
///             {"name": "revision", "type": "shortstring"}
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
///     "domain": {"name": "Starknet Mail", "version": "1", "chainId": "1", "revision": 1},
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

    public let revision: Revision
    private let allTypes: [String: [TypeDeclarationWrapper]]
    private let hashMethod: StarknetHashMethod

    fileprivate enum CodingKeys: CodingKey {
        case types
        case primaryType
        case domain
        case message
    }

    private func hashArray(_ values: [Felt]) -> Felt {
        hashMethod.hash(values: values)
    }

    private init(types: [String: [any TypeDeclaration]], primaryType: String, domain: Domain, message: [String: Element]) throws {
        self.types = types.mapValues { value in
            value.map { TypeDeclarationWrapper($0) }
        }
        self.primaryType = primaryType
        self.domain = domain
        self.message = message

        self.revision = domain.revision

        self.allTypes = self.types.merging(
            Self.PresetType.cases(revision: self.revision).reduce(into: [:]) { $0[$1.rawValue] = $1.params },
            uniquingKeysWith: { current, _ in current }
        )

        self.hashMethod = switch revision {
        case .v0: .pedersen
        case .v1: .poseidon
        }

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
            throw StarknetTypedDataError.dependencyNotDefined(domain.separatorName)
        }

        let basicTypes = Self.BasicType.cases(revision: revision).map(\.rawValue)
        let presetTypes = Self.PresetType.cases(revision: revision).reduce(into: [:]) { $0[$1.rawValue] = $1.params }

        let referencedTypes = try Set(types.values.flatMap { type in
            try type.flatMap { param in
                switch param {
                case let .enum(enumType):
                    return [enumType.contains]
                case let .merkletree(merkle):
                    return [merkle.contains]
                case let .standard(standard):
                    if standard.type.isEnum() {
                        guard revision == .v1 else {
                            throw StarknetTypedDataError.unsupportedType(standard.type)
                        }
                        return try standard.type.extractEnumTypes()
                    } else {
                        return [standard.type.strippingPointer()]
                    }
                }
            }
        } + [domain.separatorName, primaryType])

        try self.types.keys.forEach { typeName in
            guard !basicTypes.contains(typeName) else {
                throw StarknetTypedDataError.basicTypeRedefinition(typeName)
            }
            guard presetTypes[typeName] == nil else {
                throw StarknetTypedDataError.presetTypeRedefinition(typeName)
            }
            guard !typeName.isEmpty,
                  !typeName.isArray(),
                  !typeName.isEnum(),
                  !typeName.contains(",")
            else {
                throw StarknetTypedDataError.invalidTypeName(typeName)
            }
            guard referencedTypes.contains(typeName) else {
                throw StarknetTypedDataError.danglingType(typeName)
            }
        }
    }

    private func getDependencies(of type: String) throws -> [String] {
        func extractTypes(from param: TypeDeclarationWrapper) throws -> [String] {
            switch param {
            case let .enum(enumType):
                guard revision == .v1 else {
                    throw StarknetTypedDataError.unsupportedType(BasicType.enum.rawValue)
                }
                return [enumType.contains]
            default:
                let paramType = param.type.type
                if paramType.isEnum() {
                    guard revision == .v1 else {
                        throw StarknetTypedDataError.unsupportedType(paramType)
                    }
                    return try paramType.extractEnumTypes()
                } else {
                    return [paramType]
                }
            }
        }

        var dependencies = [type]
        var toVisit = [type]

        while !toVisit.isEmpty {
            let currentType = toVisit.removeFirst()
            let params = allTypes[currentType] ?? []

            try params.forEach { param in
                let extractedTypes = try extractTypes(from: param).map { $0.strippingPointer() }

                for extractedType in extractedTypes {
                    if allTypes.keys.contains(extractedType), !dependencies.contains(extractedType) {
                        dependencies.append(extractedType)
                        toVisit.append(extractedType)
                    }
                }
            }
        }

        let sorted = dependencies.suffix(from: 1).sorted()

        return [dependencies[0]] + Array(sorted)
    }

    private func encode(dependency: String) throws -> String {
        func escape(_ string: String) -> String {
            switch revision {
            case .v0: string
            case .v1: "\"\(string)\""
            }
        }
        func resolveTargetType(from param: TypeDeclarationWrapper) throws -> String {
            switch param {
            case let .enum(enumType):
                guard revision == .v1 else {
                    throw StarknetTypedDataError.unsupportedType(BasicType.enum.rawValue)
                }
                return enumType.contains
            default:
                return param.type.type
            }
        }
        func encodeEnumTypes(from type: String) throws -> String {
            guard revision == .v1 else {
                throw StarknetTypedDataError.unsupportedType(BasicType.enum.rawValue)
            }

            let enumTypes = try type.extractEnumTypes().map(escape).joined(separator: ",")
            return "(\(enumTypes))"
        }

        guard let params = allTypes[dependency] else {
            throw StarknetTypedDataError.dependencyNotDefined(dependency)
        }

        let encodedParams = try params.map {
            let targetType = try resolveTargetType(from: $0)
            let typeString = if targetType.isEnum() {
                try encodeEnumTypes(from: targetType)
            } else {
                escape(targetType)
            }
            return "\(escape($0.type.name)):\(typeString)"
        }.joined(separator: ",")

        return "\(escape(dependency))(\(encodedParams))"
    }

    func encode(type: String) throws -> String {
        let dependencies = try getDependencies(of: type)

        return try dependencies.map {
            try encode(dependency: $0)
        }.joined()
    }

    func encode(element: Element, forType typeName: String, context: Context? = nil) throws -> Felt {
        if allTypes.keys.contains(typeName) {
            let object = try unwrapObject(from: element)

            return try getStructHash(typeName: typeName, data: object)
        }

        if typeName.isArray() {
            let array = try unwrapArray(from: element)

            let hashes = try array.map {
                try encode(element: $0, forType: typeName.strippingPointer())
            }

            return hashArray(hashes)
        }

        let basicType = BasicType(rawValue: typeName)
        switch (basicType, revision) {
        case (.felt, _), (.string, .v0), (.shortstring, .v1), (.contractAddress, .v1), (.classHash, .v1):
            return try unwrapFelt(from: element)
        case (.u128, .v1), (.timestamp, .v1):
            return try unwrapU128(from: element)
        case (.i128, .v1):
            return try unwrapI128(from: element)
        case (.bool, _):
            return try unwrapBool(from: element)
        case (.string, .v1):
            return try hashArray(unwrapLongString(from: element))
        case (.selector, _):
            return try unwrapSelector(from: element)
        case (.enum, .v1):
            guard let context else {
                throw StarknetTypedDataError.contextNotDefined
            }
            return try unwrapEnum(from: element, context: context)
        case (.merkletree, _):
            guard let context else {
                throw StarknetTypedDataError.contextNotDefined
            }
            return try prepareMerkleTreeRoot(from: element, context: context)
        case (.some, .v0):
            throw StarknetTypedDataError.unsupportedType(typeName)
        case (nil, _):
            throw StarknetTypedDataError.dependencyNotDefined(typeName)
        }
    }

    private func encode(data: [String: Element], forType typeName: String) throws -> [Felt] {
        var values: [Felt] = []

        guard let types = allTypes[typeName] else {
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

        return try hashArray([getTypeHash(typeName: typeName)] + encodedData)
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
        try hashArray([
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
        public let revision: Revision

        fileprivate enum CodingKeys: CodingKey {
            case name
            case version
            case chainId
            case revision
        }

        public var separatorName: String {
            switch revision {
            case .v0: "StarkNetDomain"
            case .v1: "StarknetDomain"
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(Element.self, forKey: .name)
            self.version = try container.decode(Element.self, forKey: .version)
            self.chainId = try container.decode(Element.self, forKey: .chainId)
            self.revision = try container.decodeIfPresent(Revision.self, forKey: .revision) ?? .v0
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(String(describing: version), forKey: .version)
            try container.encode(chainId, forKey: .chainId)
            try container.encode(revision, forKey: .revision)
        }
    }

    enum Revision: String, Codable, Equatable {
        case v0 = "0"
        case v1 = "1"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self), let value = Revision(rawValue: stringValue) {
                self = value
            } else if let intValue = try? container.decode(Int.self), let value = Revision(rawValue: String(intValue)) {
                self = value
            } else {
                throw StarknetTypedDataError.decodingError
            }
        }
    }

    enum Element: Codable, Hashable, Equatable {
        case object([String: Element])
        case array([Element])
        case string(String)
        case felt(Felt)
        case signedFelt(Felt)
        case bool(Bool)
        case decimal(UInt64)
        case signedDecimal(Int64)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let object = try? container.decode([String: Element].self) {
                self = .object(object)
            } else if let array = try? container.decode([Element].self) {
                self = .array(array)
            } else if let uint = try? container.decode(UInt64.self) {
                self = .decimal(UInt64(uint))
            } else if let int = try? container.decode(Int64.self) {
                self = .signedDecimal(Int64(int))
            } else if let felt = try? container.decode(Felt.self) {
                self = .felt(felt)
            } else if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else if let string = try? container.decode(String.self) {
                if let uint = UInt64(string) {
                    self = .decimal(uint)
                } else if let int = Int64(string) {
                    self = .signedDecimal(int)
                } else if let uint = BigUInt(string),
                          let felt = Felt(uint)
                {
                    self = .felt(felt)
                } else if let int = BigInt(string),
                          let felt = Felt(fromSigned: int)
                {
                    self = .signedFelt(felt)
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
            case let .decimal(decimal):
                try decimal.encode(to: encoder)
            case let .signedDecimal(signedDecimal):
                try signedDecimal.encode(to: encoder)
            case let .felt(felt):
                try felt.encode(to: encoder)
            case let .signedFelt(felt):
                try felt.encode(to: encoder)
            case let .object(object):
                try object.encode(to: encoder)
            case let .array(array):
                try array.encode(to: encoder)
            case let .bool(bool):
                try bool.encode(to: encoder)
            }
        }
    }
}

extension StarknetTypedData {
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
        case let .decimal(decimal):
            guard let felt = Felt(decimal) else {
                throw StarknetTypedDataError.decodingError
            }
            return felt
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

    func unwrapU128(from element: Element) throws -> Felt {
        switch element {
        case let .decimal(decimal):
            guard decimal < BigUInt(2).power(128) else {
                throw StarknetTypedDataError.invalidNumericValue(element)
            }
            return Felt(integerLiteral: decimal)
        case let .felt(felt):
            guard felt.value < BigUInt(2).power(128) else {
                throw StarknetTypedDataError.invalidNumericValue(element)
            }
            return felt
        default:
            throw StarknetTypedDataError.invalidNumericValue(element)
        }
    }

    func unwrapI128(from element: Element) throws -> Felt {
        let felt: Felt

        switch element {
        case let .decimal(decimalValue):
            felt = Felt(decimalValue)!
        case let .signedDecimal(signedDecimalValue):
            felt = Felt(fromSigned: signedDecimalValue)!
        case let .felt(feltValue):
            felt = feltValue
        case let .signedFelt(signedFeltValue):
            felt = signedFeltValue
        default:
            throw StarknetTypedDataError.invalidNumericValue(element)
        }

        guard felt.value < BigUInt(2).power(127) || felt.value >= Felt.prime - BigUInt(2).power(127) else {
            throw StarknetTypedDataError.invalidNumericValue(element)
        }

        return felt
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

    func unwrapLongString(from element: Element) throws -> [Felt] {
        guard case let .string(string) = element else {
            throw StarknetTypedDataError.decodingError
        }

        let byteArray = StarknetByteArray(fromString: string)

        return [Felt(byteArray.data.count)!]
            + byteArray.data
            + [byteArray.pendingWord, Felt(byteArray.pendingWordLen)!]
    }

    func unwrapBool(from element: Element) throws -> Felt {
        switch element {
        case let .decimal(decimal):
            guard decimal == 0 || decimal == 1 else {
                throw StarknetTypedDataError.invalidBool(element)
            }
            return decimal == 0 ? .zero : .one
        case let .felt(felt):
            guard felt == .zero || felt == .one else {
                throw StarknetTypedDataError.invalidBool(element)
            }
            return felt
        case let .bool(bool):
            return bool ? .one : .zero
        case let .string(string):
            guard let bool = Bool(string) else {
                throw StarknetTypedDataError.invalidBool(element)
            }
            return bool ? .one : .zero
        default:
            throw StarknetTypedDataError.invalidBool(element)
        }
    }

    func unwrapEnum(from element: Element, context: Context) throws -> Felt {
        let object = try unwrapObject(from: element)

        guard let variant = object.first else {
            throw StarknetTypedDataError.decodingError
        }
        let variantName = variant.key
        guard case let .array(variantData) = variant.value else {
            throw StarknetTypedDataError.decodingError
        }

        let variants = try getEnumVariants(context: context)
        let variantType = variants.first { $0.type.name == variantName }
        guard let variantType else {
            throw StarknetTypedDataError.decodingError
        }
        guard let variantIndex = variants.firstIndex(of: variantType) else {
            throw StarknetTypedDataError.decodingError
        }

        let encodedSubtypes = try variantType.type.type.extractEnumTypes().enumerated().map { index, subtype in
            let subtypeData = variantData[index]
            return try encode(element: subtypeData, forType: subtype)
        }

        return hashArray([Felt(variantIndex)!] + encodedSubtypes)
    }

    private func getEnumVariants(context: Context) throws -> [TypeDeclarationWrapper] {
        let enumType: EnumType = try resolveType(context)

        guard let variants = allTypes[enumType.contains] else {
            throw StarknetTypedDataError.dependencyNotDefined(enumType.contains)
        }

        return variants
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

    private func getMerkleTreeLeavesType(context: Context) throws -> String {
        let merkleType: MerkleTreeType = try resolveType(context)

        return merkleType.contains
    }

    private func resolveType<T: TypeDeclaration>(_ context: Context) throws -> T {
        let (parent, key) = (context.parent, context.key)

        guard let parentType = allTypes[parent] else {
            throw StarknetTypedDataError.parentNotDefined
        }
        guard let targetType = parentType.first(where: { $0.type.name == key }) else {
            throw StarknetTypedDataError.keyNotDefined
        }
        guard let targetType = targetType.type as? T else {
            throw StarknetTypedDataError.decodingError
        }

        return targetType
    }
}

extension StarknetTypedData.Element: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .string(s):
            s
        case let .decimal(n):
            String(n)
        case let .signedDecimal(n):
            String(n)
        case let .felt(f):
            f.toHex()
        case let .signedFelt(f):
            f.toHex()
        case let .bool(b):
            String(b)
        case .object:
            String(describing: self)
        case .array:
            String(describing: self)
        }
    }
}

private extension String {
    func strippingPointer() -> String {
        if self.isArray() {
            return String(self.dropLast(1))
        }

        return self
    }

    func extractEnumTypes() throws -> [String] {
        guard self.isEnum() else {
            throw StarknetTypedDataError.decodingError
        }

        let content = self[self.index(after: self.startIndex) ..< self.index(before: self.endIndex)]
        return content.isEmpty ? [] : content.split(separator: ",").map { String($0) }
    }

    func isArray() -> Bool {
        self.hasSuffix("*")
    }

    func isEnum() -> Bool {
        self.hasPrefix("(") && self.hasSuffix(")")
    }
}
