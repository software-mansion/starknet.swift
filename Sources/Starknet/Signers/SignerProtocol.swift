import Foundation

public protocol StarknetSignerProtocol {
    /// Public key associated with given signer
    var publicKey: Felt? { get }
    
    /// Sign transaction
    ///
    /// - Parameters:
    ///  - transaction: transaction to be signed
    ///
    /// - Returns: Starknet signature of given transaction
    func sign(transaction: StarknetTransaction) throws -> StarknetSignature
}
