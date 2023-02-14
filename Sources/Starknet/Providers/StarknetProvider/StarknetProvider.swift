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

    private func makeRequest<U>(method: JsonRpcMethod, params: some Encodable = EmptyEncodable(), receive _: U.Type) async throws -> U where U: Decodable {
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

    public func estimateFee(for transaction: StarknetSequencerTransaction, at blockId: StarknetBlockId) async throws -> StarknetEstimateFeeResponse {
        let params = EstimateFeeParams(request: transaction, blockId: blockId)

        let result = try await makeRequest(method: .estimateFee, params: params, receive: StarknetEstimateFeeResponse.self)

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
}
