import Foundation

public enum StarknetDAMode: String, Codable {
    case L1
    case L2

    public var value: UInt {
        switch self {
        case .L1:
            return 0
        case .L2:
            return 1
        }
    }
}
