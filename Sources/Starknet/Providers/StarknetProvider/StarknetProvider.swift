import Foundation

public enum StarknetProviderError: Error {
    case networkProviderError
    case unknownError
    case jsonRpcError(Int, String, String?)
    case emptyRequestsError
}

public class StarknetProvider: StarknetProviderProtocol {
    private let url: URL
    private let networkProvider: HttpNetworkProvider

    public init(url: URL) {
        self.url = url
        self.networkProvider = HttpNetworkProvider()
    }

    public convenience init?(url: String) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(url: url)
    }

    public init(url: URL, urlSession: URLSession) {
        self.url = url
        self.networkProvider = HttpNetworkProvider(session: urlSession)
    }

    public convenience init?(url: String, urlSession: URLSession) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(url: url, urlSession: urlSession)
    }

    public func send<U>(request: StarknetRequest<U>) async throws -> U {
        let rpcPayload = JsonRpcPayload(method: request.method, params: request.params)
        let response = try await networkProvider.send(
            payload: rpcPayload,
            config: prepareHttpRequestConfiguration(),
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

    public func send<U>(
        requests: [StarknetRequest<U>]
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable {
        guard !requests.isEmpty else {
            throw StarknetProviderError.emptyRequestsError
        }

        let rpcPayloads = requests.enumerated().map { index, request -> JsonRpcPayload in
            JsonRpcPayload(method: request.method, params: request.params, id: index)
        }
        let config = prepareHttpRequestConfiguration()

        let rpcResponses = try await networkProvider.send(
            payload: rpcPayloads,
            config: config,
            receive: [JsonRpcResponse<U>.self]
        )

        return orderRpcResults(rpcResponses: rpcResponses)
    }

    public func send<U>(
        requests: StarknetRequest<U>...
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable {
        try await send(requests: requests)
    }
}

private extension StarknetProvider {
    private func prepareHttpRequestConfiguration() -> HttpNetworkProvider.Configuration {
        HttpNetworkProvider.Configuration(
            url: url,
            method: "POST",
            params: [
                (header: "Content-Type", value: "application/json"),
                (header: "Accept", value: "application/json"),
            ]
        )
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
