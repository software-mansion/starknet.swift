import Foundation

/// Provider used to interact with the StakNet blockchain.
public protocol StarknetProviderProtocol {
    var starknetChainId: StarknetChainId { get }
    
    /// Call starknet contract.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///     - blockId: hash, number, or tag of a block at which the call should be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    func callContract(_ call: Call, at blockId: BlockId) async throws -> [Felt]
}

private let defaultBlockId = BlockId.tag(.latest)

public extension StarknetProviderProtocol {
    /// Call starknet contract at the latest block.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    func callContract(_ call: Call) async throws -> [Felt] {
        return try await callContract(call, at: defaultBlockId)
    }
}
