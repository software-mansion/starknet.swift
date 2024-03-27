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
        }

        case standard(StandardType)
        case merkletree(MerkleTreeType)

        public var type: any TypeDeclaration {
            switch self {
            case let .standard(type):
                return type
            case let .merkletree(type):
                return type
            }
        }

        public init(_ type: any TypeDeclaration) {
            switch type {
            case let type as StandardType:
                self = .standard(type)
            case let type as MerkleTreeType:
                self = .merkletree(type)
            default:
                self = .standard(.init(name: type.name, type: type.type))
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            let type = try container.decode(String.self, forKey: Keys.type)

            switch type {
            case "merkletree":
                self = try .merkletree(MerkleTreeType(from: decoder))
            default:
                self = try .standard(StandardType(from: decoder))
            }
        }
    }
}
