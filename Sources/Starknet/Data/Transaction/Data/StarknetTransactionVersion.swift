import Foundation

public enum StarknetTransactionVersion: String, Codable {
    case v0 = "0x0"
    case v1 = "0x1"
    case v1Query = "0x100000000000000000000000000000001"
    case v2 = "0x2"
    case v2Query = "0x100000000000000000000000000000002"
    case v3 = "0x3"
    case v3Query = "0x100000000000000000000000000000003"

    public var value: Felt {
        Felt(fromHex: self.rawValue)!
    }
}
