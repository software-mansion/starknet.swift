public struct BinaryNode: MerkleNode {
    let left: Felt
    let right: Felt

    public func isEqual(to other: any MerkleNode) throws -> Bool {
        guard type(of: other) == BinaryNode.self else {
            throw MerkleNodeError.typeMismatch(expected: "BinaryNode", found: "\(type(of: other))")
        }

        let otherBinaryNode = other as! BinaryNode
        return self == otherBinaryNode
    }

    public static func == (lhs: BinaryNode, rhs: BinaryNode) -> Bool {
        lhs.left == rhs.left && lhs.right == rhs.right
    }
}
