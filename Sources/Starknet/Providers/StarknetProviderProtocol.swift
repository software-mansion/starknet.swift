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
    func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) async throws -> [Felt]

    /// Get nonce of given starknet contract
    ///
    /// - Parameters
    ///     - contract: address of a contract, for which the nonce should be returned.
    ///     - blockId: hash, number, or tag of a block at which the call should be made.
    ///
    /// - Returns: Felt value of contract's current nonce.
    func getNonce(of contract: Felt, at blockId: StarknetBlockId) async throws -> Felt

    /// Estimate fee for a transaction.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for wich the fee should be estimated.
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    /// - Returns: EstimateFeeResponse object
    func estimateFee(for transaction: any StarknetSequencerTransaction, at blockId: StarknetBlockId) async throws -> StarknetEstimateFeeResponse

    /// Invoke a function.
    ///
    /// Invoke a function in deployed contract.
    ///
    /// - Parameters
    ///     - payload: invoke function payload.
    ///
    /// - Returns: transaction hash of invoked transaction.
    func addInvokeTransaction(_ transaction: StarknetSequencerInvokeTransaction) async throws -> StarknetInvokeTransactionResponse

    /// Deploy account
    ///
    /// Deploy prefunded starknet account.
    ///
    /// - Parameters:
    ///  - transaction: deploy account transaction to be executed
    /// - Returns: transaction hash and contract address of deployed account
    func addDeployAccountTransaction(_ transaction: StarknetSequencerDeployAccountTransaction) async throws -> StarknetDeployAccountResponse

    /// Get the contract class hash for the contract deployed at the given address.
    ///
    /// - Parameters:
    ///  - address: address of the contract whose address will be returned
    ///  - blockId: id of the requested block
    /// - Returns: Class hash of the given contract
    func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) async throws -> Felt

    /// Get the most recent accepted block number.
    ///
    /// - Returns: Number of the most recent accepted block
    func getBlockNumber() async throws -> UInt64

    /// Get the most recent accepted block hash and number.
    ///
    /// - Returns: Block hash and block number  of the most recent accepted block
    func getBlockHashAndNumber() async throws -> StarknetBlockHashAndNumber

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    /// - Returns: Transaction found with provided hash
    func getTransactionBy(hash: Felt) async throws -> StarknetTransaction

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - blockId: id of block from which the transaction should be returned.
    ///  - index: index of transaction in the block
    /// - Returns: Transaction found with provided blockId and index.
    func getTransactionBy(blockId: StarknetBlockId, index: UInt64) async throws -> StarknetTransaction
}

private let defaultBlockId = StarknetBlockId.tag(.latest)

public extension StarknetProviderProtocol {
    /// Call starknet contract at the latest block.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    func callContract(_ call: StarknetCall) async throws -> [Felt] {
        try await callContract(call, at: defaultBlockId)
    }

    /// Estimate fee for a transaction in the latest block.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    /// - Returns: EstimateFeeResponse object
    func estimateFee(for transaction: any StarknetSequencerTransaction) async throws -> StarknetEstimateFeeResponse {
        try await estimateFee(for: transaction, at: .tag(.latest))
    }

    /// Get nonce of given starknet contract at latest block.
    ///
    /// - Parameters
    ///     - contract: address of a contract, for which the nonce should be returned.
    ///
    /// - Returns: Felt value of contract's current nonce.
    func getNonce(of contract: Felt) async throws -> Felt {
        try await getNonce(of: contract, at: defaultBlockId)
    }

    /// Get the contract class hash for the contract deployed at the given address.
    ///
    /// - Parameters:
    ///  - address: address of the contract whose address will be returned
    /// - Returns: Class hash of the given contract
    func getClassHashAt(_ address: Felt) async throws -> Felt {
        try await getClassHashAt(address, at: .tag(.latest))
    }
}
