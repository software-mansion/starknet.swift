import BigInt
import Foundation

/// Estimates the transaction tip by taking the median of all V3 transaction tips in the latest block.
///
/// - Parameter provider: The provider used to interact with Starknet.
/// - Returns: The estimated median tip.
/// - Throws: An error if the RPC call fails or no transactions are found.
public func estimateTip(provider: StarknetProviderProtocol) async throws -> UInt64AsHex {
    try await estimateTip(provider: provider, blockId: .tag(.latest))
}

/// Estimates the transaction tip by taking the median of all V3 transaction tips in the latest block.
///
/// - Parameters:
///   - provider: The provider used to interact with Starknet.
///   - blockHash: The block hash to estimate tip for.
/// - Returns: The estimated median tip.
/// - Throws: An error if the RPC call fails or no transactions are found.
public func estimateTip(provider: StarknetProviderProtocol, blockHash: Felt) async throws -> UInt64AsHex {
    try await estimateTip(provider: provider, blockId: .hash(blockHash))
}

/// Estimates the transaction tip by taking the median of all V3 transaction tips in the latest block.
///
/// - Parameters:
///   - provider: The provider used to interact with Starknet.
///   - blockNumber: The block number to estimate tip for.
/// - Returns: The estimated median tip.
/// - Throws: An error if the RPC call fails or no transactions are found.
public func estimateTip(provider: StarknetProviderProtocol, blockNumber: Int) async throws -> UInt64AsHex {
    try await estimateTip(provider: provider, blockId: .number(blockNumber))
}

/// Estimates the transaction tip by taking the median of all V3 transaction tips in the latest block.
///
/// - Parameters:
///   - provider: The provider used to interact with Starknet.
///   - blockTag: The block tag to estimate tip for.
/// - Returns: The estimated median tip.
/// - Throws: An error if the RPC call fails or no transactions are found.
public func estimateTip(provider: StarknetProviderProtocol, blockTag: StarknetBlockId.BlockTag) async throws -> UInt64AsHex {
    try await estimateTip(provider: provider, blockId: .tag(blockTag))
}

/// Estimates the transaction tip by taking the median of all V3 transaction tips in the specified block.
///
/// - Parameters:
///   - provider: The provider used to interact with Starknet.
///   - blockId: The block identifier to estimate the tip for (hash, number, or tag).
/// - Returns: The estimated median tip.
/// - Throws: An error if the RPC call fails or no transactions are found.
private func estimateTip(provider: StarknetProviderProtocol, blockId: StarknetBlockId) async throws -> UInt64AsHex {
    let request = RequestBuilder.getBlockWithTxs(blockId)
    let blockWithTxs = try await provider.send(request: request)

    let transactions: [TransactionWrapper] = switch blockWithTxs {
    case let .processed(block): block.transactions
    case let .preConfirmed(block): block.transactions
    }

    let tips = transactions.compactMap { transactionWrapper in
        switch transactionWrapper {
        case let .invokeV3(invokeV3): invokeV3.tip.value
        case let .deployAccountV3(deployAccountV3): deployAccountV3.tip.value
        case let .declareV3(declareV3): declareV3.tip.value
        default: nil
        }
    }

    if tips.isEmpty {
        return UInt64AsHex.zero
    }

    let sortedTips = tips.sorted()
    let count = sortedTips.count

    let median = if count % 2 == 1 {
        sortedTips[count / 2]
    } else {
        (sortedTips[count / 2 - 1] + sortedTips[count / 2]) / 2
    }

    if let median = median.toUInt64AsHex() {
        return median
    } else {
        fatalError("Failed to convert BigUInt to UInt64AsHex")
    }
}
