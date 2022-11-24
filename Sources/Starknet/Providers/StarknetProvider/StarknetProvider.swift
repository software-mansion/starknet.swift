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
    
    private func execute<T, U>(method: JsonRpcMethod, params: T, receive: U.Type) async throws -> U where T: Encodable, U: Decodable {
        let rpcPayload = JsonRpcPayload(method: method, params: params)
        
        var response: JsonRpcResponse<U>
        
        let config = HttpNetworkProvider.Configuration(url: url, method: "POST", params: [
            (header: "Content-Type", value: "application/json"),
            (header: "Accept", value: "application/json")
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
        
        let result = try await execute(method: .call, params: params, receive: [Felt].self)
        
        return result
    }
}
