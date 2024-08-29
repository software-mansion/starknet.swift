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

    /// Send multiple RPC requests
    ///
    /// - Parameters
    ///     - requests: list of requests to be sent.
    ///
    /// - Returns: requests' result.
    func send<U>(
        requests: [StarknetRequest<U>]
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable

    /// Send multiple RPC requests
    ///
    /// - Parameters
    ///     - requests: requests to be sent.
    ///
    /// - Returns: requests' result.
    func send<U>(
        requests: StarknetRequest<U>...
    ) async throws -> [Result<U, StarknetProviderError>] where U: Decodable
}
