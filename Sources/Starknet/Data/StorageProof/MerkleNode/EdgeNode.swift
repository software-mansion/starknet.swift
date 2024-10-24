public struct EdgeNode: MerkleNode {
    let path: Int
    let length: Int
    let value: Felt

    public func isEqual(to other: any MerkleNode) throws -> Bool {
        guard type(of: other) == EdgeNode.self else {
            throw MerkleNodeError.typeMismatch(expected: "EdgeNode", found: "\(type(of: other))")
        }

        let otherEdgeNode = other as! EdgeNode
        return self == otherEdgeNode
    }

    public static func == (lhs: EdgeNode, rhs: EdgeNode) -> Bool {
        lhs.path == rhs.path && lhs.length == rhs.length && lhs.value == rhs.value
    }
}
