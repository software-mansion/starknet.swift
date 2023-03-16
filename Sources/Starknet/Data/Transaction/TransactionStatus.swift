import Foundation

public enum StarknetTransactionStatus: String, Codable {
    case pending = "PENDING"
    case rejected = "REJECTED"
    case acceptedL1 = "ACCEPTED_ON_L1"
    case acceptedL2 = "ACCEPTED_ON_L2"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}
