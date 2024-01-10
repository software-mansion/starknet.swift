
public protocol StarknetTransaction: Codable, Hashable, Equatable {
    var type: StarknetTransactionType { get }
    var version: Felt { get }
    var hash: Felt? { get }
}
