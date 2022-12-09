import Foundation

public enum StarknetTransactionType: String, Codable {
    case invoke = "INVOKE"
    
    public var encodedValue: Felt {
        return Felt.fromShortString(self.rawValue)!
    }
}
