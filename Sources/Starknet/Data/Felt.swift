import Foundation
import BigInt

public struct Felt {
    public let value: BigUInt
    
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

extension Felt {
    public init?(_ data: Data) {
        let value = BigUInt(data)
        
        self.init(value)
    }
    
    public func serialize() -> Data {
        return value.serialize()
    }
}

extension Felt {
    public static func fromShortString(_ string: String) -> Felt? {
        guard string.count <= 31 else {
            return nil
        }
        
        guard string.allSatisfy(\.isASCII) else {
            return nil
        }
        
        let encoded = string.map {
            String($0.asciiValue!, radix: 16)
        }.joined()
        
        return Felt(fromHex: "0x" + encoded)
    }
    
    public func toShortString() -> String {
        var hexString = String(self.value, radix: 16)
        
        if hexString.count % 2 == 1 {
            hexString = "0" + hexString
        }
        
        let pairs = hexString.components(withMaxLength: 2)
        
        return pairs.map {
            return "\(UnicodeScalar(Int($0, radix: 16)!)!)"
        }.joined()
    }
}

private extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
