public extension StarknetTypedData {
    protocol TypeDeclaration: Codable, Equatable, Hashable {
        var name: String { get }
        var type: String { get }
    }

    struct StandardType: TypeDeclaration {
        public let name: String
        public let type: String

        public init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }

    struct EnumType: TypeDeclaration {
        public let name: String
        public let type: String = "enum"
        public let contains: String

        public init(name: String, contains: String) {
            self.name = name
            self.contains = contains
        }

        fileprivate enum CodingKeys: String, CodingKey {
            case name
            case contains
        }
    }

    struct MerkleTreeType: TypeDeclaration {
        public let name: String
        public let type: String = "merkletree"
        public let contains: String

        public init(name: String, contains: String) {
            self.name = name
            self.contains = contains
        }

        fileprivate enum CodingKeys: String, CodingKey {
            case name
            case contains
        }
    }

    enum TypeDeclarationWrapper: Codable, Hashable, Equatable {
        fileprivate enum Keys: String, CodingKey {
            case type
            case contains
        }

        case standard(StandardType)
        case `enum`(EnumType)
        case merkletree(MerkleTreeType)

        public var type: any TypeDeclaration {
            switch self {
            case let .standard(type):
                type
            case let .enum(type):
                type
            case let .merkletree(type):
                type
            }
        }

        public init(_ type: any TypeDeclaration) {
            switch type {
            case let type as StandardType:
                self = .standard(type)
            case let type as EnumType:
                self = .enum(type)
            case let type as MerkleTreeType:
                self = .merkletree(type)
            default:
                self = .standard(.init(name: type.name, type: type.type))
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            let type = try container.decode(String.self, forKey: Keys.type)
            let contains = try container.decodeIfPresent(String.self, forKey: Keys.contains)

            switch type {
            case "enum":
                self = if contains != nil {
                    try .enum(EnumType(from: decoder))
                } else {
                    try .standard(StandardType(from: decoder))
                }
            case "merkletree":
                self = try .merkletree(MerkleTreeType(from: decoder))
            default:
                self = try .standard(StandardType(from: decoder))
            }
        }
    }
}
