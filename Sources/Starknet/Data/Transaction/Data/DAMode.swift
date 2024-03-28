import BigInt
import Foundation

public enum StarknetDAMode: String, Codable {
    case l1 = "L1"
    case l2 = "L2"

    public var value: BigUInt {
        switch self {
        case .l1:
            0
        case .l2:
            1
        }
    }
}
