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

    func send() async throws -> [U] {
        let responses: [JsonRpcResponse<U>] = try await networkProvider.sendBatch(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        var orderedResults: [U?] = Array(repeating: nil, count: rpcPayloads.count)
        for response in responses {
            orderedResults[response.id] = response.result
        }

        return orderedResults.compactMap { $0 }
    }
}
