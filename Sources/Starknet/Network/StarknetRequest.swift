public struct StarknetRequest<U: Decodable> {
    let method: JsonRpcMethod
    let params: JsonRpcParams
}

let defaultBlockId = StarknetBlockId.tag(.pending)
let defaultSimulationFlagsForEstimateFee: Set<StarknetSimulationFlagForEstimateFee> = []

public enum RequestBuilder {
    /// Get the version of the Starknet JSON-RPC specification being used by the node.
    ///
    ///  - Returns: the version of the Starknet JSON-RPC specification being used.
    static func getSpecVersion() -> StarknetRequest<String> {
        let params = EmptyParams()

        return StarknetRequest<String>(method: .specVersion, params: .empty(params))
    }

    /// Call starknet contract.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///     - blockId: hash, number, or tag of a block at which the call should be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    static func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) -> StarknetRequest<[Felt]> {
        let params = CallParams(request: call, blockId: blockId)

        return StarknetRequest<[Felt]>(method: .call, params: .call(params))
    }

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: the fee estimation
    static func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) -> StarknetRequest<StarknetFeeEstimate> {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        return StarknetRequest<StarknetFeeEstimate>(method: .estimateMessageFee, params: .estimateMessageFee(params))
    }

    /// Estimate fee for a transaction.
    ///
    /// - Parameters:
    ///  - transactions: list of transactions for which the fees should be estimated.
    ///  - blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: Array of fee estimates
    static func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> StarknetRequest<[StarknetFeeEstimate]> {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        return StarknetRequest<[StarknetFeeEstimate]>(method: .estimateFee, params: .estimateFee(params))
    }

    /// Get nonce of given starknet contract
    ///
    /// - Parameters
    ///     - contract: address of a contract, for which the nonce should be returned.
    ///     - blockId: hash, number, or tag of a block at which the call should be made.
    ///
    /// - Returns: Felt value of contract's current nonce.
    static func getNonce(of contract: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt> {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        return StarknetRequest<Felt>(method: .getNonce, params: .getNonce(params))
    }

    /// Invoke a function.
    ///
    /// Invoke a function in deployed contract.
    ///
    /// - Parameters
    ///     - payload: invoke function payload.
    ///
    /// - Returns: transaction hash of invoked transaction.
    static func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) -> StarknetRequest<StarknetInvokeTransactionResponse> {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        return StarknetRequest<StarknetInvokeTransactionResponse>(method: .invokeFunction, params: .addInvokeTransaction(params))
    }

    /// Deploy account
    ///
    /// Deploy prefunded starknet account.
    ///
    /// - Parameters:
    ///  - transaction: deploy account transaction to be executed
    ///
    /// - Returns: transaction hash and contract address of deployed account
    static func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) -> StarknetRequest<StarknetDeployAccountResponse> {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        return StarknetRequest<StarknetDeployAccountResponse>(method: .deployAccount, params: .addDeployAccountTransaction(params))
    }

    /// Get the contract class hash for the contract deployed at the given address.
    ///
    /// - Parameters:
    ///  - address: address of the contract whose address will be returned
    ///  - blockId: id of the requested block
    ///
    /// - Returns: Class hash of the given contract
    static func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt> {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        return StarknetRequest<Felt>(method: .getClassHashAt, params: .getClassHashAt(params))
    }

    /// Get the most recent accepted block number.
    ///
    /// - Returns: Number of the most recent accepted block
    static func getBlockNumber() -> StarknetRequest<UInt64> {
        let params = EmptySequence()

        return StarknetRequest<UInt64>(method: .getBlockNumber, params: .emptySequence(params))
    }

    /// Get the most recent accepted block hash and number.
    ///
    /// - Returns: Block hash and block number  of the most recent accepted block
    static func getBlockHashAndNumber() -> StarknetRequest<StarknetBlockHashAndNumber> {
        let params = EmptySequence()

        return StarknetRequest<StarknetBlockHashAndNumber>(method: .getBlockHashAndNumber, params: .emptySequence(params))
    }

    /// Get all event objects matching the conditions in the provided filter
    ///
    /// - Parameters:
    ///  - filter : the conditions used to filter the returned events
    ///
    /// - Returns: events matching the conditions in the provided filter and continuation token
    static func getEvents(filter: StarknetGetEventsFilter) -> StarknetRequest<StarknetGetEventsResponse> {
        let params = GetEventsPayload(filter: filter)

        return StarknetRequest<StarknetGetEventsResponse>(method: .getEvents, params: .getEvents(params))
    }

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    ///
    /// - Returns: Transaction found with provided hash
    static func getTransactionBy(hash: Felt) -> StarknetRequest<TransactionWrapper> {
        let params = GetTransactionByHashParams(hash: hash)

        return StarknetRequest<TransactionWrapper>(method: .getTransactionByHash, params: .getTransactionByHash(params))
    }

    /// Get the details and status of a submitted transaction
    ///
    /// - Parameters:
    ///  - blockId: id of block from which the transaction should be returned.
    ///  - index: index of transaction in the block
    ///
    /// - Returns: Transaction found with provided blockId and index.
    static func getTransactionBy(blockId: StarknetBlockId, index: UInt64) -> StarknetRequest<TransactionWrapper> {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        return StarknetRequest<TransactionWrapper>(method: .getTransactionByBlockIdAndIndex, params: .getTransactionByBlockIdAndIndex(params))
    }

    /// Get transaction receipt of a submitted transaction
    ///
    /// - Parameters:
    ///  - hash : the hash of the requested transaction
    ///
    /// - Returns: receipt of a transaction identified by given hash
    static func getTransactionReceiptBy(hash: Felt) -> StarknetRequest<TransactionReceiptWrapper> {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        return StarknetRequest<TransactionReceiptWrapper>(method: .getTransactionReceipt, params: .getTransactionReceipt(params))
    }

    /// Get the status of a submitted transaction.
    ///
    /// - Parameters:
    ///  - hash: The hash of the requested transaction
    ///
    /// - Returns: The status(es) of a transaction
    static func getTransactionStatusBy(hash: Felt) -> StarknetRequest<StarknetGetTransactionStatusResponse> {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        return StarknetRequest<StarknetGetTransactionStatusResponse>(method: .getTransactionStatus, params: .getTransactionStatus(params))
    }

    /// Get the currently configured Starknet chain id
    ///
    /// - Returns: The Starknet chain id
    static func getChainId() -> StarknetRequest<StarknetChainId> {
        let params = EmptySequence()

        return StarknetRequest<StarknetChainId>(method: .getChainId, params: .emptySequence(params))
    }

    /// Simulate running a given list of transactions, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - blockId: block used to run the simulation
    ///  - simulationFlags: a set of simulation flags
    ///
    ///  - Returns: array of simulated transactions
    static func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) -> StarknetRequest<[StarknetSimulatedTransaction]> {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        return StarknetRequest<[StarknetSimulatedTransaction]>(method: .simulateTransactions, params: .simulateTransactions(params))
    }

    /// Call starknet contract in the pending block.
    ///
    /// - Parameters
    ///     - call: starknet call to be made.
    ///
    /// - Returns: Array of field elements, returned by called contract.
    static func callContract(_ call: StarknetCall) -> StarknetRequest<[Felt]> {
        RequestBuilder.callContract(call, at: defaultBlockId)
    }

    /// Estimate fee for a list of transactions with default flags in the pending block.
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///
    /// - Returns: Array of fee estimates
    static func estimateFee(for transactions: [any StarknetExecutableTransaction]) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: transactions, at: defaultBlockId, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of transactions with default flags.
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///  -  blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: Array of fee estimates
    static func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: transactions, at: blockId, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of transactions in the pending block..
    ///
    /// - Parameters:
    ///  -  transactions: transactions for which the fees should be estimated.
    ///  -  simulationFlags: a set of simulation flags
    ///
    /// - Returns: Array of fee estimates
    static func estimateFee(for transactions: [any StarknetExecutableTransaction], simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: transactions, at: defaultBlockId, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a single transaction with default flags in the pending block.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    ///
    /// - Returns: Fee estimate
    static func estimateFee(for transaction: any StarknetExecutableTransaction) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: [transaction])
    }

    /// Estimate fee for a single transaction with default flags.
    ///
    /// - Parameters:
    ///  -  transaction: transaction for which the fee should be estimated.
    ///  -  blockId: hash, numer, or tag of a block for which the estimation should be made.
    ///
    /// - Returns: Fee estimate
    static func estimateFee(for transaction: any StarknetExecutableTransaction, at blockId: StarknetBlockId) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: [transaction], at: blockId)
    }

    /// Estimate fee for a single transaction in the pending block..
    ///
    /// - Parameters:
    ///  -  transaction: transactions for which the fees should be estimated.
    ///  -  simulationFlags: a set of simulation flags
    ///
    /// - Returns: Fee estimate
    static func estimateFee(for transaction: any StarknetExecutableTransaction, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> StarknetRequest<[StarknetFeeEstimate]> {
        estimateFee(for: [transaction], simulationFlags: simulationFlags)
    }

    /// Estimate the L2 fee of a message sent on L1
    ///
    /// - Parameters:
    ///  - message: the message's parameters
    ///
    /// - Returns: Fee estimate
    static func estimateMessageFee(_ message: StarknetMessageFromL1) -> StarknetRequest<StarknetFeeEstimate> {
        estimateMessageFee(message, at: defaultBlockId)
    }

    /// Get nonce of given starknet contract in the pending block.
    ///
    /// - Parameters
    ///     - contract: address of a contract, for which the nonce should be returned.
    ///
    /// - Returns: Felt value of contract's current nonce.
    static func getNonce(of contract: Felt) -> StarknetRequest<Felt> {
        getNonce(of: contract, at: defaultBlockId)
    }

    /// Get the contract class hash for the contract deployed at the given address.
    ///
    /// - Parameters:
    ///  - address: address of the contract whose address will be returned
    ///
    /// - Returns: Class hash of the given contract
    static func getClassHashAt(_ address: Felt) -> StarknetRequest<Felt> {
        getClassHashAt(address, at: defaultBlockId)
    }

    /// Simulate running a given list of transactions in the latest block, and generate the execution trace
    ///
    /// - Parameters:
    ///  - transactions: list of transactions to simulate
    ///  - simulationFlags: a set of simulation flags
    ///
    ///  - Returns : array of simulated transactions
    static func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], simulationFlags: Set<StarknetSimulationFlag>) -> StarknetRequest<[StarknetSimulatedTransaction]> {
        simulateTransactions(transactions, at: defaultBlockId, simulationFlags: simulationFlags)
    }
}
