import Foundation

public protocol StarknetSignerProtocol {
    /// Public key associated with given signer
    var publicKey: Felt { get }

    /// Sign transaction
    ///
    /// - Parameters:
    ///  - transaction: transaction to be signed
    ///
    /// - Returns: Starknet signature of given transaction
    func sign(transaction: any StarknetTransaction) throws -> StarknetSignature

    /// Sign TypedData object.
    ///
    /// - Parameters:
    ///  - typedData: TypedData instance to sign
    ///  - accountAddress: address to be used for calculating message hash.
    /// - Returns: Starknet signature for message hash of a given TypedData.
    func sign(typedData: StarknetTypedData, accountAddress: Felt) throws -> StarknetSignature
}
