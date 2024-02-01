import BigInt
import Foundation

public struct UInt64AsHex: NumAsHexProtocol {
    public let value: BigUInt

    public static let zero = UInt64AsHex(0)
    public static let one = UInt64AsHex(1)

    public static let min = UInt64AsHex.zero
    public static let max = UInt64AsHex(maxValue)!
    private static let maxValue = BigUInt(2).power(64) - 1

    public init?(_ exactly: some BinaryInteger) {
        let value = BigUInt(exactly: exactly)

        guard let value, value <= UInt64AsHex.maxValue else {
            return nil
        }

        self.value = value
    }

    public init(clamping: some BinaryInteger) {
        let value = BigUInt(clamping: clamping)

        self.value = value <= UInt64AsHex.maxValue ? value : UInt64AsHex.maxValue
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

extension UInt64AsHex: CustomDebugStringConvertible {
    public var debugDescription: String {
        "UInt64AsHex: \(self.value)"
    }
}
