
public protocol StarknetSequencerTransaction: Codable {
    var type: StarknetTransactionType { get }
    var version: Felt { get }
}

public protocol StarknetTransaction: StarknetSequencerTransaction {
    var hash: Felt { get }
}
