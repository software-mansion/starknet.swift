public struct StarknetRequest<U: Decodable> {
    let method: JsonRpcMethod
    let params: JsonRpcParams
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    public func send() async throws -> U {
        let rpcPayload = JsonRpcPayload(method: method, params: params)
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
