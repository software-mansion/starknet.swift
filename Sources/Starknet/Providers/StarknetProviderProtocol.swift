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
    ///  - transactions: list of transactions for which the fees should be estimated.
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetSequencerTransaction], at blockId: StarknetBlockId) async throws -> [StarknetFeeEstimate]

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///  - senderAddress: the L1 address of the sender
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    /// - Returns: the fee estimation
    func estimateMessageFee(_ message: StarknetCall, senderAddress: Felt, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate

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

    /// Get all event objects matching the conditions in the provided filter
    ///
    /// - Parameters:
    ///  - filter : the conditions used to filter the returned events
    /// - Returns: events matching the conditions in the provided filter and continuation token
    func getEvents(filter: StarknetGetEventsFilter) async throws -> StarknetGetEventsResponse

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    /// - Returns: Transaction found with provided hash
    func getTransactionBy(hash: Felt) async throws -> any StarknetTransaction

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - blockId: id of block from which the transaction should be returned.
    ///  - index: index of transaction in the block
    /// - Returns: Transaction found with provided blockId and index.
    func getTransactionBy(blockId: StarknetBlockId, index: UInt64) async throws -> any StarknetTransaction

    /// Get all event objects matching the conditions in the provided filter
    ///
    /// - Parameters:
    ///  - txHash : the hash of the requested transaction
    /// - Returns: receipt of a transaction identified by given hash
    func getTransactionReceiptBy(hash: Felt) async throws -> StarknetTransactionReceipt

    /// Simulate running a given list of transactions, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - blockId: block used to run the simulation
    ///  - simulationFlags: a set of simulation flags
    func simulateTransactions(_ transactions: [any StarknetSequencerTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction]
}

let defaultBlockId = StarknetBlockId.tag(.pending)

public extension StarknetProviderProtocol {
    /// Call starknet contract in the pending block.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    func callContract(_ call: StarknetCall) async throws -> [Felt] {
        try await callContract(call, at: defaultBlockId)
    }

    /// Estimate fee for a list of transactions in the pending block.
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetSequencerTransaction]) async throws -> [StarknetFeeEstimate] {
        try await estimateFee(for: transactions, at: defaultBlockId)
    }

    /// Estimate fee for a single transaction
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    ///  -  blockId: hash, numer, or tag of a block for which the estimation should be made.
    /// - Returns: Fee estimate
    func estimateFee(for transaction: any StarknetSequencerTransaction, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate {
        let estimate = try await estimateFee(for: [transaction], at: blockId)
        return estimate[0]
    }

    /// Estimate fee for a single transaction in the pending block
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    /// - Returns: Fee estimate
    func estimateFee(for transaction: any StarknetSequencerTransaction) async throws -> StarknetFeeEstimate {
        try await estimateFee(for: transaction, at: defaultBlockId)
    }

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///  - senderAddress: the L1 address of the sender
    /// - Returns: the fee estimation
    func estimateMessageFee(_ message: StarknetCall, senderAddress: Felt) async throws -> StarknetFeeEstimate {
        try await estimateMessageFee(message, senderAddress: senderAddress, at: defaultBlockId)
    }

    /// Get nonce of given starknet contract in the pending block.
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
        try await getClassHashAt(address, at: defaultBlockId)
    }

    /// Simulate running a given list of transactions in the latest block, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - simulationFlags: a set of simulation flags
    func simulateTransactions(_ transactions: [any StarknetSequencerTransaction], simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction] {
        try await simulateTransactions(transactions, at: defaultBlockId, simulationFlags: simulationFlags)
    }
}
