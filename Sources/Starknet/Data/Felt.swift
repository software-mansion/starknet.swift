import Foundation
import BigInt

public struct Felt {
    internal let value: BigUInt
    
    public static let prime = BigUInt(2).power(251) + 17 * BigUInt(2).power(192) + 1
    
    public static let zero = Felt(0)!
    public static let one = Felt(1)!
    
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

// TODO: Conform to UnsignedInteger protocol
