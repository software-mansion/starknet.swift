import Foundation

public enum StarknetTransactionType: String, Codable {
    case invoke = "INVOKE"
    case deployAccount = "DEPLOY_ACCOUNT"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}
