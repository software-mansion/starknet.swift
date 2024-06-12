public struct StarknetBatchRequest<U: Decodable> {
    let rpcPayloads: [JsonRpcPayload]
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    public func send() async throws -> [Result<U, StarknetProviderError>] {
        let rpcResponses = try await networkProvider.send(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        return orderRpcResults(rpcResponses: rpcResponses)
    }
}

func orderRpcResults<U: Decodable>(rpcResponses: [JsonRpcResponse<U>]) -> [Result<U, StarknetProviderError>] {
    var orderedRpcResults: [Result<U, StarknetProviderError>?] = Array(repeating: nil, count: rpcResponses.count)
    for rpcResponse in rpcResponses {
        if let result = rpcResponse.result {
            orderedRpcResults[rpcResponse.id] = .success(result)
        } else if let error = rpcResponse.error {
            orderedRpcResults[rpcResponse.id] = .failure(StarknetProviderError.jsonRpcError(error.code, error.message, error.data))
        } else {
            orderedRpcResults[rpcResponse.id] = .failure(StarknetProviderError.unknownError)
        }
    }

    return orderedRpcResults.compactMap { $0 }
}
