public class StarknetBatchRequest<U: Decodable, P: Encodable> {
    let rpcPayloads: [JsonRpcPayload<P>]
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    init(
        rpcPayloads: [JsonRpcPayload<P>],
        config: HttpNetworkProvider.Configuration,
        networkProvider: HttpNetworkProvider
    ) {
        self.rpcPayloads = rpcPayloads
        self.config = config
        self.networkProvider = networkProvider
    }

    private func getOrderedRpcResults(rpcResponses: [JsonRpcResponse<U>]) -> [Result<U, StarknetProviderError>] {
        var orderedRpcResults: [Result<U, StarknetProviderError>?] = Array(repeating: nil, count: rpcPayloads.count)
        for rpcResponse in rpcResponses {
            if let error = rpcResponse.error {
                orderedRpcResults[rpcResponse.id] = .failure(StarknetProviderError.jsonRpcError(error.code, error.message, error.data))
            } else if let result = rpcResponse.result {
                orderedRpcResults[rpcResponse.id] = .success(result)
            } else {
                orderedRpcResults[rpcResponse.id] = .failure(StarknetProviderError.unknownError)
            }
        }

        return orderedRpcResults.compactMap { $0 }
    }

    func send() async throws -> [Result<U, StarknetProviderError>] {
        let rpcResponses: [JsonRpcResponse<U>] = try await networkProvider.send(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        return getOrderedRpcResults(rpcResponses: rpcResponses)
    }
}
