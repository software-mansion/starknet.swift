public class BatchRequest<U: Decodable, P: Encodable> {
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

    func send() async throws -> [Result<U, StarknetProviderError>] {
        let responses: [JsonRpcResponse<U>] = try await networkProvider.sendBatch(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        var orderedResults: [Result<U, StarknetProviderError>?] = Array(repeating: nil, count: rpcPayloads.count)
        for response in responses {
            if let error = response.error {
                orderedResults[response.id] = .failure(StarknetProviderError.jsonRpcError(error.code, error.message, error.data))
            } else if let result = response.result {
                orderedResults[response.id] = .success(result)
            } else {
                orderedResults[response.id] = .failure(StarknetProviderError.unknownError)
            }
        }

        return orderedResults.compactMap { $0 }
    }
}
