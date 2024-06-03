import Foundation

public enum StarknetProviderError: Error {
    case networkProviderError
    case unknownError
    case jsonRpcError(Int, String, String?)
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

    private func buildRequest<U: Decodable, P: Encodable>(method: JsonRpcMethod, params: P) -> StarknetRequest<U, P> {
        let config = prepareHttpRequestConfiguration()
        return StarknetRequest<U, P>(method: method, params: params, config: config, networkProvider: networkProvider)
    }

    /// Batch multiple HTTP requests with JSON-RPC calls together into a single HTTP request
    ///
    /// - Parameters
    ///     - requests: list of HTTP requests to be batched together.
    ///
    /// - Returns: batch HTTP request.
    public func batchRequests<U: Decodable, P: Encodable>(requests: [StarknetRequest<U, P>]) -> StarknetBatchRequest<U, P> {
        let rpcPayloads = requests.enumerated().map { index, request in
            JsonRpcPayload(method: request.method, params: request.params, id: index)
        }
        let config = prepareHttpRequestConfiguration()

        return StarknetBatchRequest<U, P>(rpcPayloads: rpcPayloads, config: config, networkProvider: networkProvider)
    }

    /// Batch multiple HTTP requests with JSON-RPC calls together into a single HTTP request
    ///
    /// - Parameters
    ///     - requests: one or more HTTP requests to be batched together.
    ///
    /// - Returns: batch HTTP request.
    public func batchRequests<U: Decodable, P: Encodable>(requests: StarknetRequest<U, P>...) -> StarknetBatchRequest<U, P> {
        batchRequests(requests: requests)
    }

    public func specVersion() -> StarknetRequest<String, EmptyParams> {
        let params = EmptyParams()

        return buildRequest(method: .specVersion, params: params)
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) -> StarknetRequest<[Felt], CallParams> {
        let params = CallParams(request: call, blockId: blockId)

        return buildRequest(method: .call, params: params)
    }

    public func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) -> StarknetRequest<StarknetFeeEstimate, EstimateMessageFeeParams> {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        return buildRequest(method: .estimateMessageFee, params: params)
    }

    public func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> StarknetRequest<[StarknetFeeEstimate], EstimateFeeParams> {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        return buildRequest(method: .estimateFee, params: params)
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt, GetNonceParams> {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        return buildRequest(method: .getNonce, params: params)
    }

    public func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) -> StarknetRequest<StarknetInvokeTransactionResponse, AddInvokeTransactionParams> {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        return buildRequest(method: .invokeFunction, params: params)
    }

    public func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) -> StarknetRequest<StarknetDeployAccountResponse, AddDeployAccountTransactionParams> {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        return buildRequest(method: .deployAccount, params: params)
    }

    public func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) -> StarknetRequest<Felt, GetClassHashAtParams> {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        return buildRequest(method: .getClassHashAt, params: params)
    }

    public func getBlockNumber() -> StarknetRequest<UInt64, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockNumber, params: params)
    }

    public func getBlockHashAndNumber() -> StarknetRequest<StarknetBlockHashAndNumber, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockHashAndNumber, params: params)
    }

    public func getEvents(filter: StarknetGetEventsFilter) -> StarknetRequest<StarknetGetEventsResponse, GetEventsPayload> {
        let params = GetEventsPayload(filter: filter)

        return buildRequest(method: .getEvents, params: params)
    }

    public func getTransactionBy(hash: Felt) -> StarknetRequest<TransactionWrapper, GetTransactionByHashParams> {
        let params = GetTransactionByHashParams(hash: hash)

        return buildRequest(method: .getTransactionByHash, params: params)
    }

    public func getTransactionBy(blockId: StarknetBlockId, index: UInt64) -> StarknetRequest<TransactionWrapper, GetTransactionByBlockIdAndIndex> {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        return buildRequest(method: .getTransactionByBlockIdAndIndex, params: params)
    }

    public func getTransactionReceiptBy(hash: Felt) -> StarknetRequest<TransactionReceiptWrapper, GetTransactionReceiptPayload> {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionReceipt, params: params)
    }

    public func getTransactionStatusBy(hash: Felt) -> StarknetRequest<StarknetGetTransactionStatusResponse, GetTransactionStatusPayload> {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionStatus, params: params)
    }

    public func getChainId() -> StarknetRequest<StarknetChainId, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getChainId, params: params)
    }

    public func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) -> StarknetRequest<[StarknetSimulatedTransaction], SimulateTransactionsParams> {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        return buildRequest(method: .simulateTransactions, params: params)
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
