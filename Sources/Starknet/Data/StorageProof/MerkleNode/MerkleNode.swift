public protocol MerkleNode: Codable {
    func isEqual(to other: any MerkleNode) throws -> Bool
}

enum MerkleNodeError: Error, CustomStringConvertible {
    case typeMismatch(expected: String, found: String)

    var description: String {
        switch self {
        case let .typeMismatch(expected, found):
            "Cannot compare \(expected) with \(found)"
        }
    }
}
