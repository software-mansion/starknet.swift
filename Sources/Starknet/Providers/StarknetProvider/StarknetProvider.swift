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

    private func makeRequest<U>(method: JsonRpcMethod, params: some Encodable = EmptyParams(), receive _: U.Type) async throws -> U where U: Decodable {
        let rpcPayload = JsonRpcPayload(method: method, params: params)

        var response: JsonRpcResponse<U>

        let config = HttpNetworkProvider.Configuration(url: url, method: "POST", params: [
            (header: "Content-Type", value: "application/json"),
            (header: "Accept", value: "application/json"),
        ])

        do {
            response = try await networkProvider.send(payload: rpcPayload, config: config, receive: JsonRpcResponse<U>.self)
        } catch let error as HttpNetworkProviderError {
            throw error
        } catch {
            throw StarknetProviderError.unknownError
        }

        if let result = response.result {
            return result
        } else if let error = response.error {
            throw StarknetProviderError.jsonRpcError(error.code, error.message, error.data)
        } else {
            throw StarknetProviderError.unknownError
        }
    }

    public func specVersion() async throws -> String {
        let params = EmptySequence()

        let result = try await makeRequest(method: .specVersion, params: params, receive: String.self)

        return result
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) async throws -> [Felt] {
        let params = CallParams(request: call, blockId: blockId)

        let result = try await makeRequest(method: .call, params: params, receive: [Felt].self)

        return result
    }

    public func estimateMessageFee(_ message: StarknetMessageFromL1, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate {
        let params = EstimateMessageFeeParams(message: message, blockId: blockId)

        let result = try await makeRequest(method: .estimateMessageFee, params: params, receive: StarknetFeeEstimate.self)

        return result
    }

    public func estimateFee(for transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> [StarknetFeeEstimate] {
        let params = EstimateFeeParams(request: transactions, simulationFlags: simulationFlags, blockId: blockId)

        let result = try await makeRequest(method: .estimateFee, params: params, receive: [StarknetFeeEstimate].self)
        return result
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) async throws -> Felt {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        let result = try await makeRequest(method: .getNonce, params: params, receive: Felt.self)

        return result
    }

    public func addInvokeTransaction(_ transaction: any StarknetExecutableInvokeTransaction) async throws -> StarknetInvokeTransactionResponse {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        let result = try await makeRequest(method: .invokeFunction, params: params, receive: StarknetInvokeTransactionResponse.self)

        return result
    }

    public func addDeployAccountTransaction(_ transaction: any StarknetExecutableDeployAccountTransaction) async throws -> StarknetDeployAccountResponse {
        let params = AddDeployAccountTransactionParams(deployAccountTransaction: transaction)

        let result = try await makeRequest(method: .deployAccount, params: params, receive: StarknetDeployAccountResponse.self)

        return result
    }

    public func getClassHashAt(_ address: Felt, at blockId: StarknetBlockId) async throws -> Felt {
        let params = GetClassHashAtParams(contractAddress: address, blockId: blockId)

        let result = try await makeRequest(method: .getClassHashAt, params: params, receive: Felt.self)

        return result
    }

    public func getBlockNumber() async throws -> UInt64 {
        let params = EmptySequence()
        let result = try await makeRequest(method: .getBlockNumber, params: params, receive: UInt64.self)

        return result
    }

    public func getBlockHashAndNumber() async throws -> StarknetBlockHashAndNumber {
        let params = EmptySequence()
        let result = try await makeRequest(method: .getBlockHashAndNumber, params: params, receive: StarknetBlockHashAndNumber.self)

        return result
    }

    public func getEvents(filter: StarknetGetEventsFilter) async throws -> StarknetGetEventsResponse {
        let params = GetEventsPayload(filter: filter)

        let result = try await makeRequest(method: .getEvents, params: params, receive: StarknetGetEventsResponse.self)

        return result
    }

    public func getTransactionBy(hash: Felt) async throws -> any StarknetTransaction {
        let params = GetTransactionByHashParams(hash: hash)

        let result = try await makeRequest(method: .getTransactionByHash, params: params, receive: TransactionWrapper.self)

        return result.transaction
    }

    public func getTransactionBy(blockId: StarknetBlockId, index: UInt64) async throws -> any StarknetTransaction {
        let params = GetTransactionByBlockIdAndIndex(blockId: blockId, index: index)

        let result = try await makeRequest(method: .getTransactionByBlockIdAndIndex, params: params, receive: TransactionWrapper.self)

        return result.transaction
    }

    public func getTransactionReceiptBy(hash: Felt) async throws -> any StarknetTransactionReceipt {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        let result = try await makeRequest(method: .getTransactionReceipt, params: params, receive: TransactionReceiptWrapper.self)

        return result.transactionReceipt
    }

    public func getTransactionStatusBy(hash: Felt) async throws -> StarknetGetTransactionStatusResponse {
        let params = GetTransactionStatusPayload(transactionHash: hash)

        let result = try await makeRequest(method: .getTransactionStatus, params: params, receive: StarknetGetTransactionStatusResponse.self)

        return result
    }

    public func getChainId() async throws -> StarknetChainId {
        let params = EmptySequence()

        let result = try await makeRequest(method: .getChainId, params: params, receive: StarknetChainId.self)

        return result
    }

    public func simulateTransactions(_ transactions: [any StarknetExecutableTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction] {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        let result = try await makeRequest(method: .simulateTransactions, params: params, receive: [StarknetSimulatedTransaction].self)

        return result
    }
}
