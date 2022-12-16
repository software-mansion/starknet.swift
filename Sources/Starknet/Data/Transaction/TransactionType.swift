import Foundation

public enum StarknetTransactionType: String, Codable {
    case invoke = "invoke"
    
    public var encodedValue: Felt {
        return Felt.fromShortString(self.rawValue.uppercased())!
    }
}
