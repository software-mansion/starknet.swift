import Foundation

public enum StarknetProviderError: Error {
    case networkProviderError
    case unknownError
    case jsonRpcError(Int, String)
}

public class StarknetProvider: StarknetProviderProtocol {
    public let starknetChainId: StarknetChainId

    private let url: URL
    private let networkProvider: HttpNetworkProvider

    public init(starknetChainId: StarknetChainId, url: URL) {
        self.starknetChainId = starknetChainId
        self.url = url
        self.networkProvider = HttpNetworkProvider()
    }

    public convenience init?(starknetChainId: StarknetChainId, url: String) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(starknetChainId: starknetChainId, url: url)
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
        } catch _ as HttpNetworkProviderError {
            throw StarknetProviderError.networkProviderError
        } catch {
            throw StarknetProviderError.unknownError
        }

        if let result = response.result {
            return result
        } else if let error = response.error {
            throw StarknetProviderError.jsonRpcError(error.code, error.message)
        } else {
            throw StarknetProviderError.unknownError
        }
    }

    public func callContract(_ call: StarknetCall, at blockId: StarknetBlockId) async throws -> [Felt] {
        let params = CallParams(request: call, blockId: blockId)

        let result = try await makeRequest(method: .call, params: params, receive: [Felt].self)

        return result
    }

    public func estimateMessageFee(_ message: StarknetCall, senderAddress: Felt, at blockId: StarknetBlockId) async throws -> StarknetFeeEstimate {
        let params = EstimateMessageFeeParams(message: message, senderAddress: senderAddress, blockId: blockId)

        let result = try await makeRequest(method: .estimateMessageFee, params: params, receive: StarknetFeeEstimate.self)

        return result
    }

    public func estimateFee(for transactions: [any StarknetSequencerTransaction], at blockId: StarknetBlockId) async throws -> [StarknetFeeEstimate] {
        let params = EstimateFeeParams(request: transactions, blockId: blockId)

        let result = try await makeRequest(method: .estimateFee, params: params, receive: [StarknetFeeEstimate].self)
        return result
    }

    public func getNonce(of contract: Felt, at blockId: StarknetBlockId) async throws -> Felt {
        let params = GetNonceParams(contractAddress: contract, blockId: blockId)

        let result = try await makeRequest(method: .getNonce, params: params, receive: Felt.self)

        return result
    }

    public func addInvokeTransaction(_ transaction: StarknetSequencerInvokeTransaction) async throws -> StarknetInvokeTransactionResponse {
        let params = AddInvokeTransactionParams(invokeTransaction: transaction)

        let result = try await makeRequest(method: .invokeFunction, params: params, receive: StarknetInvokeTransactionResponse.self)

        return result
    }

    public func addDeployAccountTransaction(_ transaction: StarknetSequencerDeployAccountTransaction) async throws -> StarknetDeployAccountResponse {
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
        let result = try await makeRequest(method: .getBlockNumber, receive: UInt64.self)

        return result
    }

    public func getBlockHashAndNumber() async throws -> StarknetBlockHashAndNumber {
        let result = try await makeRequest(method: .getBlockHashAndNumber, receive: StarknetBlockHashAndNumber.self)

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

    public func getTransactionReceiptBy(hash: Felt) async throws -> StarknetTransactionReceipt {
        let params = GetTransactionReceiptPayload(transactionHash: hash)

        let result = try await makeRequest(method: .getTransactionReceipt, params: params, receive: TransactionReceiptWrapper.self)

        return result.transactionReceipt
    }

    public func simulateTransactions(_ transactions: [any StarknetSequencerTransaction], at blockId: StarknetBlockId, simulationFlags: Set<StarknetSimulationFlag>) async throws -> [StarknetSimulatedTransaction] {
        let params = SimulateTransactionsParams(transactions: transactions, blockId: blockId, simulationFlags: simulationFlags)

        let result = try await makeRequest(method: .simulateTransaction, params: params, receive: [StarknetSimulatedTransaction].self)

        return result
    }
}
