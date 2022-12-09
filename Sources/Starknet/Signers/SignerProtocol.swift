import Foundation

public protocol SignerProtocol {
    var publicKey: Felt? { get }
    
    func sign(transaction: StarknetTransaction) -> StarknetSignature?
}
