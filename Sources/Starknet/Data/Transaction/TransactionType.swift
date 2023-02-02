import Foundation

public enum StarknetTransactionType: String, Codable {
    case invoke = "INVOKE"
    case deployAccount = "DEPLOY_ACCOUNT"
    
    public var encodedValue: Felt {
        return Felt.fromShortString(self.rawValue.lowercased())!
    }
}
