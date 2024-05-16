public struct StarknetRequest<U: Decodable, P: Encodable> {
    let method: JsonRpcMethod
    let params: P
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    init(
        method: JsonRpcMethod,
        params: P,
        config: HttpNetworkProvider.Configuration,
        networkProvider: HttpNetworkProvider
    ) {
        self.method = method
        self.params = params
        self.config = config
        self.networkProvider = networkProvider
    }

    public func send() async throws -> U {
        let rpcPayload = JsonRpcPayload<P>(method: method, params: params)
        let response: JsonRpcResponse<U> = try await networkProvider.send(
            payload: rpcPayload,
            config: config,
            receive: JsonRpcResponse<U>.self
        )

        if let error = response.error {
            throw StarknetProviderError.jsonRpcError(error.code, error.message, error.data)
        }

        guard let result = response.result else {
            throw StarknetProviderError.unknownError
        }

        return result
    }
}
