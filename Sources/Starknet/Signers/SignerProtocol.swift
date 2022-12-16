import Foundation

public protocol StarknetSignerProtocol {
    var publicKey: Felt? { get }
    
    func sign(transaction: StarknetTransaction) throws -> StarknetSignature
}
