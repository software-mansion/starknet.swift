public typealias StarknetExecutableInvokeTransaction = StarknetExecutableTransaction & StarknetInvokeTransaction

public protocol StarknetInvokeTransaction: StarknetTransaction {
    var calldata: StarknetCalldata { get }
    var signature: StarknetSignature { get }
}

public typealias StarknetExecutableDeployAccountTransaction = StarknetDeployAccountTransaction & StarknetExecutableTransaction

public protocol StarknetDeployAccountTransaction {
    var classHash: Felt { get }
    var contractAddressSalt: Felt { get }
    var constructorCalldata: StarknetCalldata { get }
}

public protocol StarknetDeclareTransaction {
    var classHash: Felt { get }
    var senderAddress: Felt { get }
}

public protocol StarknetTransactionV3: StarknetTransaction {
    var nonce: Felt { get }
    var resourceBounds: StarknetResourceBoundsMapping { get }
    var tip: UInt64AsHex { get }
    var paymasterData: StarknetPaymasterData { get }
    var nonceDataAvailabilityMode: StarknetDAMode { get }
    var feeDataAvailabilityMode: StarknetDAMode { get }
}

public protocol StarknetDeprecatedTransaction: StarknetTransaction {
    var maxFee: Felt { get }
}

public protocol StarknetExecutableTransaction: StarknetTransaction {}

public protocol StarknetTransaction: Codable, Hashable, Equatable {
    var type: StarknetTransactionType { get }
    var version: Felt { get }
    var hash: Felt? { get }
}
