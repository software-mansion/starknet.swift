import Foundation

/// Provider used to interact with the Starknet blockchain.
public protocol StarknetProviderProtocol {
    /// Send RPC request
    ///
    /// - Parameters
    ///     - request: single request to be sent.
    ///
    /// - Returns: request result.
    func send<U>(request: StarknetRequest<U>) async throws -> U

    /// Send multiple calls in a single RPC request
    ///
    /// - Parameters
    ///     - requests: list of requests to be sent.
    ///
    /// - Returns: results of the request.
    func send<U>(
        requests: [StarknetRequest<U>]
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable

    /// Send multiple calls in a single RPC request
    ///
    /// - Parameters
    ///     - requests: requests to be sent.
    ///
    /// - Returns: results of the request.
    func send<U>(
        requests: StarknetRequest<U>...
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable
}
