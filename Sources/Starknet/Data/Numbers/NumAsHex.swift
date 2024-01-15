import BigInt
import Foundation

public struct NumAsHex: NumAsHexProtocol {
    public let value: BigUInt

    public static let zero = NumAsHex(0)
    public static let one = NumAsHex(1)

    public static let min = NumAsHex.zero

    public init?(_ exactly: some BinaryInteger) {
        let value = BigUInt(exactly: exactly)
        guard let value else {
            return nil
        }
        self.value = value
    }

    public init(clamping: some BinaryInteger) {
        let value = BigUInt(clamping: clamping)
        self.value = value
    }

    public init?(fromHex hex: String) {
        guard hex.hasPrefix("0x") else { return nil }

        if let value = BigUInt(hex.dropFirst(2), radix: 16) {
            self.init(value)
        } else {
            return nil
        }
    }
}

extension NumAsHex: CustomDebugStringConvertible {
    public var debugDescription: String {
        "NumAsHex: \(self.toHex())"
    }
}

public extension NumAsHex {
    func toFelt() -> Felt {
        Felt(self.value)!
    }
}
