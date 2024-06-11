public struct StarknetBatchRequest<U: Decodable> {
    let rpcPayloads: [JsonRpcPayload]
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    public func send() async throws -> [Result<U, StarknetProviderError>] {
        let rpcResponses: [JsonRpcResponse<U>] = try await networkProvider.send(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        return orderRpcResults(rpcResponses: rpcResponses, count: rpcPayloads.count)
    }
}

func orderRpcResults<U: Decodable>(rpcResponses: [JsonRpcResponse<U>], count: Int) -> [Result<U, StarknetProviderError>] {
    var orderedRpcResults: [Result<U, StarknetProviderError>?] = Array(repeating: nil, count: count)
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
