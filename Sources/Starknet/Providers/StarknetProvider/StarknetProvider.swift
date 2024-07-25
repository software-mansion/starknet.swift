import Foundation

public enum StarknetProviderError: Error {
    case networkProviderError
    case unknownError
    case jsonRpcError(Int, String, String?)
    case emptyBatchRequestError
}

@available(macOS 13.0.0, *)
@available(iOS 16.0.0, *)
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

    public func batchRequests<U>(requests: [any StarknetRequestProtocol<U>]) throws -> any StarknetBatchRequestProtocol<U> where U: Decodable {
        guard !requests.isEmpty else {
            throw StarknetProviderError.emptyBatchRequestError
        }

        let rpcPayloads = requests.enumerated().map { index, request in
            JsonRpcPayload(method: request.method, params: request.params, id: index)
        }
        let config = prepareHttpRequestConfiguration()

        return StarknetBatchRequest<U>(rpcPayloads: rpcPayloads, config: config, networkProvider: networkProvider)
    }

    public func batchRequests<U>(requests: any StarknetRequestProtocol<U>...) throws -> any StarknetBatchRequestProtocol<U> where U: Decodable {
        try batchRequests(requests: requests)
    }

    public func getSpecVersion() -> any StarknetRequestProtocol<String> {
        let params = EmptyParams()

        return buildRequest(method: .specVersion, params: .empty(params))
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) -> any StarknetRequestProtocol<[Felt]> {
        let params = CallParams(request: call, blockId: blockId)

        return buildRequest(method: .call, params: .call(params))
    }

    public func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) -> any StarknetRequestProtocol<StarknetFeeEstimate> {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        return buildRequest(method: .estimateMessageFee, params: .estimateMessageFee(params))
    }

    public func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> any StarknetRequestProtocol<[StarknetFeeEstimate]> {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        return buildRequest(method: .estimateFee, params: .estimateFee(params))
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) -> any StarknetRequestProtocol<Felt> {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        return buildRequest(method: .getNonce, params: .getNonce(params))
    }

    public func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) -> any StarknetRequestProtocol<StarknetInvokeTransactionResponse> {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        return buildRequest(method: .invokeFunction, params: .addInvokeTransaction(params))
    }

    public func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) -> any StarknetRequestProtocol<StarknetDeployAccountResponse> {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        return buildRequest(method: .deployAccount, params: .addDeployAccountTransaction(params))
    }

    public func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) -> any StarknetRequestProtocol<Felt> {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        return buildRequest(method: .getClassHashAt, params: .getClassHashAt(params))
    }

    public func getBlockNumber() -> any StarknetRequestProtocol<UInt64> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockNumber, params: .emptySequence(params))
    }

    public func getBlockHashAndNumber() -> any StarknetRequestProtocol<StarknetBlockHashAndNumber> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockHashAndNumber, params: .emptySequence(params))
    }

    public func getEvents(filter: StarknetGetEventsFilter) -> any StarknetRequestProtocol<StarknetGetEventsResponse> {
        let params = GetEventsPayload(filter: filter)

        return buildRequest(method: .getEvents, params: .getEvents(params))
    }

    public func getTransactionBy(hash: Felt) -> any StarknetRequestProtocol<TransactionWrapper> {
        let params = GetTransactionByHashParams(hash: hash)

        return buildRequest(method: .getTransactionByHash, params: .getTransactionByHash(params))
    }

    public func getTransactionBy(blockId: StarknetBlockId, index: UInt64) -> any StarknetRequestProtocol<TransactionWrapper> {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        return buildRequest(method: .getTransactionByBlockIdAndIndex, params: .getTransactionByBlockIdAndIndex(params))
    }

    public func getTransactionReceiptBy(hash: Felt) -> any StarknetRequestProtocol<TransactionReceiptWrapper> {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionReceipt, params: .getTransactionReceipt(params))
    }

    public func getTransactionStatusBy(hash: Felt) -> any StarknetRequestProtocol<StarknetGetTransactionStatusResponse> {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionStatus, params: .getTransactionStatus(params))
    }

    public func getChainId() -> any StarknetRequestProtocol<StarknetChainId> {
        let params = EmptySequence()

        return buildRequest(method: .getChainId, params: .emptySequence(params))
    }

    public func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) -> any StarknetRequestProtocol<[StarknetSimulatedTransaction]> {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        return buildRequest(method: .simulateTransactions, params: .simulateTransactions(params))
    }
}

@available(macOS 13.0.0, *)
@available(iOS 16.0.0, *)
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
