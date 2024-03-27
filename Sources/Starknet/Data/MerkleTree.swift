import Foundation

public struct MerkleTree {
    public let leaves: [Felt]
    public let hashMethod: HashMethod
    public let rootHash: Felt
    public let branches: [[Felt]]

    public init?(leafHashes: [Felt], hashMethod: HashMethod) {
        self.leaves = leafHashes
        self.hashMethod = hashMethod

        guard !leaves.isEmpty else {
            return nil
        }
        (self.rootHash, self.branches) = Self.build(leafHashes: leafHashes, hashMethod: hashMethod)
    }

    private static func build(leafHashes: [Felt], hashMethod: HashMethod) -> (Felt, [[Felt]]) {
        var leaves = leafHashes
        var branches: [[Felt]] = []

        while leaves.count > 1 {
            if leaves.count != leaves.count {
                branches.append(leaves)
            }
            leaves = stride(from: 0, to: leaves.count, by: 2).map {
                Self.hash(leaves[$0], ($0 + 1) < leaves.count ? leaves[$0 + 1] : .zero, hashMethod)
            }
        }

        return (leaves[0], branches)
    }

    public static func hash(_ a: Felt, _ b: Felt, _ hashMethod: HashMethod) -> Felt {
        let (aSorted, bSorted) = a < b ? (a, b) : (b, a)

        return hashMethod.hash(first: aSorted, second: bSorted)
    }
}
