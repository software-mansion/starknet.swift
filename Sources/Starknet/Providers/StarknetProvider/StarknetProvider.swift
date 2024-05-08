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

    private func buildRequest<U: Decodable, P: Encodable>(method: JsonRpcMethod, params: P) -> HttpRequest<U, P> {
        let rpcPayload = JsonRpcPayload<P>(method: method, params: params)
        let config = HttpNetworkProvider.Configuration(
            url: url,
            method: "POST",
            params: [
                (header: "Content-Type", value: "application/json"),
                (header: "Accept", value: "application/json"),
            ]
        )
        return HttpRequest<U, P>(rpcPayload: rpcPayload, config: config, networkProvider: networkProvider)
    }

    public func specVersion() -> HttpRequest<String, EmptyParams> {
        let params = EmptyParams()

        return buildRequest(method: .specVersion, params: params)
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) -> HttpRequest<[Felt], CallParams> {
        let params = CallParams(request: call, blockId: blockId)

        return buildRequest(method: .call, params: params)
    }

    public func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) -> HttpRequest<StarknetFeeEstimate, EstimateMessageFeeParams> {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        return buildRequest(method: .estimateMessageFee, params: params)
    }

    public func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) -> HttpRequest<[StarknetFeeEstimate], EstimateFeeParams> {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        return buildRequest(method: .estimateFee, params: params)
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) -> HttpRequest<Felt, GetNonceParams> {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        return buildRequest(method: .getNonce, params: params)
    }

    public func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) -> HttpRequest<StarknetInvokeTransactionResponse, AddInvokeTransactionParams> {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        return buildRequest(method: .invokeFunction, params: params)
    }

    public func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) -> HttpRequest<StarknetDeployAccountResponse, AddDeployAccountTransactionParams> {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        return buildRequest(method: .deployAccount, params: params)
    }

    public func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) -> HttpRequest<Felt, GetClassHashAtParams> {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        return buildRequest(method: .getClassHashAt, params: params)
    }

    public func getBlockNumber() -> HttpRequest<UInt64, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockNumber, params: params)
    }

    public func getBlockHashAndNumber() -> HttpRequest<StarknetBlockHashAndNumber, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getBlockHashAndNumber, params: params)
    }

    public func getEvents(filter: StarknetGetEventsFilter) -> HttpRequest<StarknetGetEventsResponse, GetEventsPayload> {
        let params = GetEventsPayload(filter: filter)

        return buildRequest(method: .getEvents, params: params)
    }

    public func getTransactionBy(hash: Felt) -> HttpRequest<TransactionWrapper, GetTransactionByHashParams> {
        let params = GetTransactionByHashParams(hash: hash)

        return buildRequest(method: .getTransactionByHash, params: params)
    }

    public func getTransactionBy(blockId: StarknetBlockId, index: UInt64) -> HttpRequest<TransactionWrapper, GetTransactionByBlockIdAndIndex> {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        return buildRequest(method: .getTransactionByBlockIdAndIndex, params: params)
    }

    public func getTransactionReceiptBy(hash: Felt) -> HttpRequest<TransactionReceiptWrapper, GetTransactionReceiptPayload> {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionReceipt, params: params)
    }

    public func getTransactionStatusBy(hash: Felt) -> HttpRequest<StarknetGetTransactionStatusResponse, GetTransactionStatusPayload> {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        return buildRequest(method: .getTransactionStatus, params: params)
    }

    public func getChainId() -> HttpRequest<StarknetChainId, EmptySequence> {
        let params = EmptySequence()

        return buildRequest(method: .getChainId, params: params)
    }

    public func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) -> HttpRequest<[StarknetSimulatedTransaction], SimulateTransactionsParams> {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        return buildRequest(method: .simulateTransactions, params: params)
    }
}
