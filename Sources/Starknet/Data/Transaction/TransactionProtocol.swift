
public protocol StarknetSequencerTransaction {
    var type: StarknetTransactionType { get }
    var version: Felt { get }
}

public protocol StarknetTransaction: StarknetSequencerTransaction {
    var hash: Felt { get }
}
