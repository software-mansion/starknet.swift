import Foundation

public enum StarknetTransactionType: String, Codable {
    case invoke = "INVOKE"
    case declare = "DECLARE"
    case deploy = "DEPLOY"
    case deployAccount = "DEPLOY_ACCOUNT"
    case l1Handler = "L1_HANDLER"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}
