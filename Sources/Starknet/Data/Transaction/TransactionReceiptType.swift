import Foundation

public enum StarknetTransactionReceiptType: String, Codable {
    case invoke = "INVOKE"
    case declare = "DECLARE"
    case deploy = "DEPLOY"
    case deployAccount = "DEPLOY_ACCOUNT"
    case l1Handler = "L1_HANDLER"
    case pending = "PENDING"

    public var encodedValue: Felt {
        Felt.fromShortString(self.rawValue.lowercased())!
    }
}
