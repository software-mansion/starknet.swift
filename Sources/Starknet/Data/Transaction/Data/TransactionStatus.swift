import Foundation

public enum StarknetTransactionExecutionStatus: String, Codable {
    case succeeded = "SUCCEEDED"
    case reverted = "REVERTED"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}

public enum StarknetTransactionFinalityStatus: String, Codable {
    case preConfirmed = "PRE_CONFIRMED"
    case acceptedL1 = "ACCEPTED_ON_L1"
    case acceptedL2 = "ACCEPTED_ON_L2"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}

public enum StarknetTransactionStatus: String, Codable {
    case received = "RECEIVED"
    case candidate = "CANDIDATE"
    case preConfirmed = "PRE_CONFIRMED"
    case acceptedL1 = "ACCEPTED_ON_L1"
    case acceptedL2 = "ACCEPTED_ON_L2"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}
