@testable import Starknet
import XCTest

final class MerkleTreeTest: XCTestCase {
    func testCalculateHashes() {
        func testCalculateHash(_ leaves: [Felt], _ hashMethod: HashMethod, _ expectedHash: Felt) {
            let applyHash: (Felt, Felt) -> Felt = { a, b in
                switch hashMethod {
                case .pedersen:
                    StarknetCurve.pedersen(first: a, second: b)
                case .poseidon:
                    StarknetPoseidon.poseidonHash(first: a, second: b)
                }
            }
            let merkleHash = MerkleTree.hash(leaves[0], leaves[1], hashMethod)
            let rawHash = applyHash(leaves[1], leaves[0])
            XCTAssertEqual(rawHash, merkleHash)
            XCTAssertEqual(expectedHash, merkleHash)
        }

        let leaves: [Felt] = ["0x12", "0xa"]
        testCalculateHash(leaves, .pedersen, "0x586699e3ba6f118227e094ad423313a2d51871507dcbc23116f11cdd79d80f2")
        testCalculateHash(leaves, .poseidon, "0x6257f1f60f7c9fd49e2718c8ad19cd8dce6b1ba4b553b2123113f22b1e9c379")

        let leaves2: [Felt] = ["0x5bb9440e27889a364bcb678b1f679ecd1347acdedcbf36e83494f857cc58026", "0x3"]
        testCalculateHash(leaves2, .pedersen, "0x551b4adb6c35d49c686a00b9192da9332b18c9b262507cad0ece37f3b6918d2")
        testCalculateHash(leaves2, .poseidon, "0xc118a3963c12777b0717d1dc89baa8b3ceed84dfd713a6bd1354676f03f021")
    }

    func testBuildFrom0Elements() {
        let leaves: [Felt] = []

        XCTAssertNil(MerkleTree(leafHashes: leaves, hashMethod: .pedersen))
        XCTAssertNil(MerkleTree(leafHashes: leaves, hashMethod: .poseidon))
    }

    func testBuildFromElements() {
        func testBuildFrom1(_ hashMethod: HashMethod) {
            let leaves: [Felt] = [1]
            let manualRootHash = leaves[0]
            testBuild(leaves, hashMethod, manualRootHash, 0)
        }

        func testBuildFrom2(_ hashMethod: HashMethod) {
            let leaves: [Felt] = [1, 2]
            let manualRootHash = MerkleTree.hash(leaves[0], leaves[1], hashMethod)
            testBuild(leaves, hashMethod, manualRootHash, 0)
        }

        func testBuildFrom4(_ hashMethod: HashMethod) {
            let leaves: [Felt] = [1, 2, 3, 4]
            let manualRootHash = MerkleTree.hash(
                MerkleTree.hash(leaves[0], leaves[1], hashMethod),
                MerkleTree.hash(leaves[2], leaves[3], hashMethod),
                hashMethod
            )
            testBuild(leaves, hashMethod, expectedRoot: manualRootHash, expectedBranchCount: 1)
        }

        func testBuildFrom6(_ hashMethod: HashMethod) {
            let leaves: [Felt] = [1, 2, 3, 4, 5, 6]
            let manualRootHash = MerkleTree.hash(
                MerkleTree.hash(
                    MerkleTree.hash(leaves[0], leaves[1], hashMethod),
                    MerkleTree.hash(leaves[2], leaves[3], hashMethod),
                    hashMethod
                ),
                MerkleTree.hash(
                    MerkleTree.hash(leaves[4], leaves[5], hashMethod),
                    .zero,
                    hashMethod
                ),
                hashMethod
            )
            testBuild(leaves, hashMethod, expectedRoot: manualRootHash, expectedBranchCount: 2)
        }

        func testBuildFrom7(_ hashMethod: HashMethod) {
            let leaves: [Felt] = [1, 2, 3, 4, 5, 6, 7]
            let manualRootHash = MerkleTree.hash(
                MerkleTree.hash(
                    MerkleTree.hash(leaves[0], leaves[1], hashMethod),
                    MerkleTree.hash(leaves[2], leaves[3], hashMethod),
                    hashMethod
                ),
                MerkleTree.hash(
                    MerkleTree.hash(leaves[4], leaves[5], hashMethod),
                    MerkleTree.hash(leaves[6], .zero, hashMethod),
                    hashMethod
                ),
                hashMethod
            )
            testBuild(leaves, hashMethod, expectedRoot: manualRootHash, expectedBranchCount: 2)
        }

        func testBuild(_ leaves: [Felt], _ hashMethod: HashMethod, expectedRoot: Felt, expectedBranchCount: Int) {
            let tree = MerkleTree(leafHashes: leaves, hashMethod: hashMethod)

            XCTAssertNotNil(tree)
            XCTAssertEqual(tree!.rootHash, expectedRoot)
            XCTAssertEqual(tree!.branches.count, expectedBranchCount)
        }

        [HashMethod.pedersen, .poseidon].forEach { hashMethod in
            testBuildFrom1(hashMethod)
            testBuildFrom2(hashMethod)
            testBuildFrom4(hashMethod)
            testBuildFrom6(hashMethod)
            testBuildFrom7(hashMethod)
        }
    }
}
