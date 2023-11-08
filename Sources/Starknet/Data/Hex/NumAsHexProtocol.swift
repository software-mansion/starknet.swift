import BigInt
import Foundation

public protocol NumAsHexProtocol: Codable, Equatable, Comparable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible where IntegerLiteralType == UInt64, StringLiteralType == String {
    var value: BigUInt { get }

    init?(_ exactly: some BinaryInteger)
    init?(fromHex hex: String)
    func toHex() -> String
}

public extension NumAsHexProtocol {
    func encode(to encoder: Encoder) throws {
        try self.toHex().encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        let string = try String(from: decoder)

        guard let initialized = Self(fromHex: string) else {
            throw HexStringDecodingError.invalidStringFormat
        }

        self = initialized
    }
}

public extension NumAsHexProtocol {
    var description: String {
        self.toHex()
    }
}

public extension NumAsHexProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }

    static func < (lhs: Self, rhs: any NumAsHexProtocol) -> Bool {
        lhs.value < rhs.value
    }

    static func == (lhs: Self, rhs: any NumAsHexProtocol) -> Bool {
        lhs.value == rhs.value
    }

    static func <= (lhs: Self, rhs: any NumAsHexProtocol) -> Bool {
        lhs.value <= rhs.value
    }
}

public extension NumAsHexProtocol {
    init(integerLiteral value: UInt64) {
        let value = BigUInt(value)
        self.init(value)!
    }
}

public extension NumAsHexProtocol {
    init(stringLiteral value: String) {
        if value.hasPrefix("0x") {
            var value = String(value)
            value.removeFirst(2)

            let bigUInt = BigUInt(value, radix: 16)!
            self.init(bigUInt)!
        } else {
            let bigUInt = BigUInt(value, radix: 10)!
            self.init(bigUInt)!
        }
    }
}

public extension NumAsHexProtocol {
    init?(_ data: Data) {
        let value = BigUInt(data)

        self.init(value)
    }

    func serialize() -> Data {
        value.serialize()
    }
}

public extension NumAsHexProtocol {
    func toShortString() -> String {
        var hexString = String(self.value, radix: 16)

        if hexString.count % 2 == 1 {
            hexString = "0" + hexString
        }

        let pairs = hexString.components(withMaxLength: 2)

        return pairs.map {
            "\(UnicodeScalar(Int($0, radix: 16)!)!)"
        }.joined()
    }
}

public extension NumAsHexProtocol {
    func toHex() -> String {
        "0x\(String(value, radix: 16))"
    }
}

internal extension String {
    func components(withMaxLength length: Int) -> [String] {
        stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start ..< end])
        }
    }
}

public enum HexStringDecodingError: Error {
    case invalidStringFormat
}
