import Foundation
import BigInt

struct Felt {
    private let value: BigUInt
    
    private static let primeBigUInt = BigUInt(2).power(251) + 17 * BigUInt(2).power(192) + 1
    
    static let zero = Felt(fromTruncated: 0)
    static let one = Felt(fromTruncated: 1)
    
    init?(_ value: BigUInt) {
        guard value < Felt.primeBigUInt else {
           return nil
        }
        
        self.value = value
    }
    
    init(fromTruncated value: BigUInt) {
        self.value = value % Felt.primeBigUInt
    }
    
    
    init?(fromHex hex: String) {
        guard hex.hasPrefix("0x") else { return nil }
        
        if let value = BigUInt(hex.dropFirst(2), radix: 16) {
            self.init(value)
        } else {
            return nil
        }
        
    }
    
    func toHex() -> String {
        return "0x\(String(value, radix: 16))"
    }
}

enum FeltDecodingError: Error {
    case invalidStringFormat
}

extension Felt: Codable {
    func encode(to encoder: Encoder) throws {
        try self.toHex().encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
        let string = try String.init(from: decoder)
        
        guard let initialized = Felt(fromHex: string) else {
            throw FeltDecodingError.invalidStringFormat
        }
        
        self = initialized
    }
}

extension Felt: Equatable {
    static func == (lhs: Felt, rhs: Felt) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Felt: Comparable {
    static func < (lhs: Felt, rhs: Felt) -> Bool {
        return lhs.value < rhs.value
    }
}

extension Felt: CustomStringConvertible {
    var description: String {
        return self.toHex()
    }
}

// TODO: Conform to UnsignedInteger protocol
