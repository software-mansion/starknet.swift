import Foundation

public protocol StarknetRequestProtocol<U> {
    associatedtype U: Decodable
    var method: JsonRpcMethod { get }
    var params: JsonRpcParams { get }
    func send() async throws -> U
}

public struct StarknetRequest<U: Decodable>: StarknetRequestProtocol {
    public let method: JsonRpcMethod
    public let params: JsonRpcParams
    let config: HttpNetworkProvider.Configuration
    let networkProvider: HttpNetworkProvider

    public func send() async throws -> U {
        let rpcPayload = JsonRpcPayload(method: method, params: params)
        let response = try await networkProvider.send(
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
