import Foundation

/// Provider used to interact with the StakNet blockchain.
public protocol StarknetProviderProtocol {
    /// Get the version of the Starknet JSON-RPC specification being used by the node.
    ///
    ///  - Returns: the version of the Starknet JSON-RPC specification being used.
    func specVersion() async throws -> String

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
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> [StarknetFeeEstimate]

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: the fee estimation
    func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate

    /// Invoke a function.
    ///
    /// Invoke a function in deployed contract.
    ///
    /// - Parameters
    ///     - payload: invoke function payload.
    ///
    /// - Returns: transaction hash of invoked transaction.
    func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) async throws -> StarknetInvokeTransactionResponse

    /// Deploy account
    ///
    /// Deploy prefunded starknet account.
    ///
    /// - Parameters:
    ///  - transaction: deploy account transaction to be executed
    ///
    /// - Returns: transaction hash and contract address of deployed account
    func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) async throws -> StarknetDeployAccountResponse

    /// Get the contract class hash for the contract deployed at the given address.
    ///
    /// - Parameters:
    ///  - address: address of the contract whose address will be returned
    ///  - blockId: id of the requested block
    ///
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
    ///
    /// - Returns: events matching the conditions in the provided filter and continuation token
    func getEvents(filter: StarknetGetEventsFilter) async throws -> StarknetGetEventsResponse

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    ///
    /// - Returns: Transaction found with provided hash
    func getTransactionBy(hash: Felt) async throws -> any StarknetTransaction

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - blockId: id of block from which the transaction should be returned.
    ///  - index: index of transaction in the block
    ///
    /// - Returns: Transaction found with provided blockId and index.
    func getTransactionBy(blockId: StarknetBlockId, index: UInt64) async throws -> any StarknetTransaction

    /// Get transaction receipt of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash : the hash of the requested transaction
    ///
    /// - Returns: receipt of a transaction identified by given hash
    func getTransactionReceiptBy(hash: Felt) async throws -> any StarknetTransactionReceipt

    /// Get the status of a submitted transaction.
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    ///
    /// - Returns: The status(es) of a transaction
    func getTransactionStatusBy(hash: Felt) async throws -> StarknetGetTransactionStatusResponse

    /// Get the currently configured Starknet chain id
    ///
    /// - Returns: The Starknet chain id
    func getChainId() async throws -> StarknetChainId

    /// Simulate running a given list of transactions, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - blockId: block used to run the simulation
    ///  - simulationFlags: a set of simulation flags
    ///
    ///  - Returns: array of simulated transactions
    func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction]
}

let defaultBlockId = StarknetBlockId.tag(.pending)
let defaultSimulationFlagsForEstimateFee: Set<StarknetSimulationFlagForEstimateFee> = []
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

    /// Estimate fee for a list of transactions with default flags in the pending block.
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetExecutableTransaction]) async throws -> [StarknetFeeEstimate] {
        try await estimateFee(for: transactions, at: defaultBlockId, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of transactions with default flags.
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///  -  blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId) async throws -> [StarknetFeeEstimate] {
        try await estimateFee(for: transactions, at: blockId, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of transactions in the pending block..
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///  -  simulationFlags: a set of simulation flags
    ///
    /// - Returns: Array of fee estimates
    func estimateFee(for transactions: [any StarknetExecutableTransaction], simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> [StarknetFeeEstimate] {
        try await estimateFee(for: transactions, at: defaultBlockId, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a single transaction with default flags in the pending block.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    ///
    /// - Returns: Fee estimate
    func estimateFee(for transaction: any StarknetExecutableTransaction) async throws -> StarknetFeeEstimate {
        try await estimateFee(for: [transaction])[0]
    }

    /// Estimate fee for a single transaction with default flags.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    ///  -  blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: Fee estimate
    func estimateFee(for transaction: any StarknetExecutableTransaction, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate {
        try await estimateFee(for: [transaction], at: blockId)[0]
    }

    /// Estimate fee for a single transaction in the pending block..
    ///
    /// - Parameters:
    ///  -  transaction: transactions for which the fees should be estimated.
    ///  -  simulationFlags: a set of simulation flags
    ///
    /// - Returns: Fee estimate
    func estimateFee(for transaction: any StarknetExecutableTransaction, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        try await estimateFee(for: [transaction], simulationFlags: simulationFlags)[0]
    }

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///
    /// - Returns: Fee estimate
    func estimateMessageFee(_ message: StarknetMessageFromL1) async throws -> StarknetFeeEstimate {
        try await estimateMessageFee(message, at: defaultBlockId)
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
    ///
    /// - Returns: Class hash of the given contract
    func getClassHashAt(_ address: Felt) async throws -> Felt {
        try await getClassHashAt(address, at: defaultBlockId)
    }

    /// Simulate running a given list of transactions in the latest block, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - simulationFlags: a set of simulation flags
    ///
    ///  - Returns : array of simulated transactions
    func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction] {
        try await simulateTransactions(transactions, at: defaultBlockId, simulationFlags: simulationFlags)
    }
}
