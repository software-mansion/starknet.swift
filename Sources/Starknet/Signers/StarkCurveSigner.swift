import Foundation

public class StarkCurveSigner: StarknetSignerProtocol {
    private let privateKey: Felt

    public let publicKey: Felt

    public init?(privateKey: Felt) {
        self.privateKey = privateKey

        do {
            self.publicKey = try StarknetCurve.getPublicKey(privateKey: self.privateKey)
        } catch {
            return nil
        }
    }

    public func sign(transaction: StarknetTransaction) throws -> StarknetSignature {
        try StarknetCurve.sign(privateKey: privateKey, hash: transaction.hash).toArray()
    }
}
