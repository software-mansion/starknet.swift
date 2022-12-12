import Foundation
import BigInt

public struct Felt {
    public let value: BigUInt
    
    public static let prime = BigUInt(2).power(251) + 17 * BigUInt(2).power(192) + 1
    
    public static let zero = Felt(0)
    public static let one = Felt(1)
    
    public static let min = Felt.zero
    public static let max = Felt(Felt.prime - 1)!
    
    public init?<T>(_ exactly: T) where T: BinaryInteger {
        let value = BigUInt(exactly: exactly)
        
        guard let value = value, value < Felt.prime else {
            return nil
        }
        
        self.value = value
    }
    
    public init<T>(clamping: T) where T: BinaryInteger {
        let value = BigUInt(clamping: clamping)
        
        self.value = value < Felt.prime ? value : Felt.prime - 1
    }
    
    
    public init?(fromHex hex: String) {
        guard hex.hasPrefix("0x") else { return nil }
        
        if let value = BigUInt(hex.dropFirst(2), radix: 16) {
            self.init(value)
        } else {
            return nil
        }
    }
    
    public func toHex() -> String {
        return "0x\(String(value, radix: 16))"
    }
}

public enum FeltDecodingError: Error {
    case invalidStringFormat
}

extension Felt: Codable {
    public func encode(to encoder: Encoder) throws {
        try self.toHex().encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        let string = try String.init(from: decoder)
        
        guard let initialized = Felt(fromHex: string) else {
            throw FeltDecodingError.invalidStringFormat
        }
        
        self = initialized
    }
}

extension Felt: Equatable {
    public static func == (lhs: Felt, rhs: Felt) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Felt: Comparable {
    public static func < (lhs: Felt, rhs: Felt) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Felt: CustomStringConvertible {
    public var description: String {
        return self.toHex()
    }
}

extension Felt: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        let value = BigUInt(value)
        self.init(value)!
    }
    
    public typealias IntegerLiteralType = UInt64
}

extension Felt: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        if (value.hasPrefix("0x")) {
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

extension Felt {
    public init?(_ data: Data) {
        let value = BigUInt(data)
        
        self.init(value)
    }
    
    public func serialize() -> Data {
        return value.serialize()
    }
}
