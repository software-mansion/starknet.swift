import Foundation

public class StarkCurveSigner: SignerProtocol {
    private let privateKey: Felt

    public private(set) lazy var publicKey: Felt? = getPublicKey()

    private func getPublicKey() -> Felt? {
        do {
            return try StarknetCurve.getPublicKey(privateKey: self.privateKey)
        } catch {
            return nil
        }
    }

    public init(privateKey: Felt) {
        self.privateKey = privateKey
    }
    
    public func sign(transaction: StarknetTransaction) -> StarknetSignature? {
        do {
            return try StarknetCurve.sign(privateKey: privateKey, hash: transaction.hash).toArray()
        } catch {
            return nil
        }
    }
}