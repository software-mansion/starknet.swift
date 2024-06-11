import Foundation

public enum StarknetProviderError: Error {
    case networkProviderError
    case unknownError
    case jsonRpcError(Int, String, String?)
    case emptyBatchRequestError
}

public class StarknetProvider: StarknetProviderProtocol {
    private let url: URL
    private let networkProvider: HttpNetworkProvider

    public init(url: URL) {
        self.url = url
        self.networkProvider = HttpNetworkProvider()
    }

    public convenience init?(url: String) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(url: url)
    }

    public init(url: URL, urlSession: URLSession) {
        self.url = url
        self.networkProvider = HttpNetworkProvider(session: urlSession)
    }

    public convenience init?(url: String, urlSession: URLSession) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(url: url, urlSession: urlSession)
    }

    private func buildRequest<U: Decodable>(method: JsonRpcMethod, params: JsonRpcParams) -> StarknetRequest<U> {
        let config = prepareHttpRequestConfiguration()
        return StarknetRequest<U>(method: method, params: params, config: config, networkProvider: networkProvider)
    }

    /// Batch multiple calls into a single RPC request
    ///
    /// - Parameters
    ///     - requests: list of requests to be batched together.
    ///
    /// - Returns: batch request.
    public func batchRequests<U: Decodable>(requests: [StarknetRequest<U>]) throws -> StarknetBatchRequest<U> {
        guard !requests.isEmpty else {
            throw StarknetProviderError.emptyBatchRequestError
        }

        let rpcPayloads = requests.enumerated().map { index, request in
            JsonRpcPayload(method: request.method, params: request.params, id: index)
        }
        let config = prepareHttpRequestConfiguration()

        return StarknetBatchRequest<U>(rpcPayloads: rpcPayloads, config: config, networkProvider: networkProvider)
    }

    /// Batch multiple calls into a single RPC request
    ///
    /// - Parameters
    ///     - requests: requests to be batched together.
    ///
    /// - Returns: batch request.
    public func batchRequests<U: Decodable>(requests: StarknetRequest<U>...) throws -> StarknetBatchRequest<U> {
        try batchRequests(requests: requests)
    }

    public func getSpecVersion() -> StarknetRequest<String> {
        let params = EmptyParams()

        return buildRequest(method: .specVersion, params: .emptyParams(params))
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) -> StarknetRequest<[Felt]> {
        let params = CallParams(request: call, blockId: blockId)

        return buildRequest(method: .call, params: .callParams(params))
    }

    public func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) -> StarknetRequest<StarknetFeeEstimate> {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        return buildRequest(method: .estimateMessageFee, params: .estimateMessageFeeParams(params))
    }

    public func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> StarknetRequest<[StarknetFeeEstimate]> {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        return buildRequest(method: .estimateFee, params: .estimateFeeParams(params))
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt> {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        return buildRequest(method: .getNonce, params: .getNonceParams(params))
    }

    public func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) -> StarknetRequest<StarknetInvokeTransactionResponse> {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        return buildRequest(method: .invokeFunction, params: .addInvokeTransactionParams(params))
    }

    public func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) -> StarknetRequest<StarknetDeployAccountResponse> {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        return buildRequest(method: .deployAccount, params: .addDeployAccountTransactionParams(params))
    }

    public func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt> {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        return buildRequest(method: .getClassHashAt, params: .getClassHashAtParams(params))
    }

    public func getBlockNumber() -> StarknetRequest<UInt64> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockNumber, params: .emptySequenceParams(params))
    }

    public func getBlockHashAndNumber() -> StarknetRequest<StarknetBlockHashAndNumber> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockHashAndNumber, params: .emptySequenceParams(params))
    }

    public func getEvents(filter: StarknetGetEventsFilter) -> StarknetRequest<StarknetGetEventsResponse> {
        let params = GetEventsPayload(filter: filter)

        return buildRequest(method: .getEvents, params: .getEventsPayload(params))
    }

    public func getTransactionBy(hash: Felt) -> StarknetRequest<TransactionWrapper> {
        let params = GetTransactionByHashParams(hash: hash)

        return buildRequest(method: .getTransactionByHash, params: .getTransactionByHashParams(params))
    }

    public func getTransactionBy(blockId: StarknetBlockId, index: UInt64) -> StarknetRequest<TransactionWrapper> {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        return buildRequest(method: .getTransactionByBlockIdAndIndex, params: .getTransactionByBlockIdAndIndex(params))
    }

    public func getTransactionReceiptBy(hash: Felt) -> StarknetRequest<TransactionReceiptWrapper> {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionReceipt, params: .getTransactionReceiptPayload(params))
    }

    public func getTransactionStatusBy(hash: Felt) -> StarknetRequest<StarknetGetTransactionStatusResponse> {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionStatus, params: .getTransactionStatusPayload(params))
    }

    public func getChainId() -> StarknetRequest<StarknetChainId> {
        let params = EmptySequence()

        return buildRequest(method: .getChainId, params: .emptySequenceParams(params))
    }

    public func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) -> StarknetRequest<[StarknetSimulatedTransaction]> {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        return buildRequest(method: .simulateTransactions, params: .simulateTransactionsParams(params))
    }
}

private extension StarknetProvider {
    private func prepareHttpRequestConfiguration() -> HttpNetworkProvider.Configuration {
        HttpNetworkProvider.Configuration(
            url: url,
            method: "POST",
            params: [
                (header: "Content-Type", value: "application/json"),
                (header: "Accept", value: "application/json"),
            ]
        )
    }
}
