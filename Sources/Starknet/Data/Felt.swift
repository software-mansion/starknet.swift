import Foundation
import BigInt

public struct Felt {
    internal let value: BigUInt
    
    public static let prime = BigUInt(2).power(251) + 17 * BigUInt(2).power(192) + 1
    
    public static let zero = Felt(0)
    public static let one = Felt(1)
    
    public static let min = Felt.zero
    public static let max = Felt(Felt.prime - 1)!
    
    public init?(_ value: BigUInt) {
        guard value < Felt.prime else {
           return nil
        }
        
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

extension Felt: AdditiveArithmetic {
    public static func - (lhs: Felt, rhs: Felt) -> Felt {
        if (rhs.value > lhs.value) {
            let value = prime - (rhs.value - lhs.value)
            return Felt(value)!
        }
        
        return Felt(lhs.value - rhs.value)!
    }
    
    public static func + (lhs: Felt, rhs: Felt) -> Felt {
        return Felt((lhs.value + rhs.value).quotientAndRemainder(dividingBy: prime).remainder)!
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

extension Felt: Numeric {
    public static func *= (lhs: inout Felt, rhs: Felt) {
        lhs = lhs * rhs
    }
    
    public var magnitude: BigUInt {
        return self.value
    }
    
    public static func * (lhs: Felt, rhs: Felt) -> Felt {
        let value = lhs.value.multiplied(by: rhs.value).quotientAndRemainder(dividingBy: prime).remainder
        
        return Felt(value)!
    }
    
    public typealias Magnitude = BigUInt
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        let value = BigUInt(exactly: source)
        
        guard let value = value else { return nil }
        
        self.init(value)
    }
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

// TODO: Conform to UnsignedInteger protocol
