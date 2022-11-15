import Foundation
import CryptoCpp
import BigInt

enum StarknetCurveError: Error {
    case deserializationError
    case verifyError
}

public class StarknetCurve {
    private static let curveOrder = BigUInt("800000000000010FFFFFFFFFFFFFFFFB781126DCAE7B2321E66A241ADC64D2F", radix: 16)!
    
    public class func pedersen(first: Felt, second: Felt) throws -> Felt {
        let result = try CryptoCpp.pedersen(first: first.toData(), second: second.toData())
        
        if let feltResult = result.toFelt() {
            return feltResult
        } else {
            throw StarknetCurveError.deserializationError
        }
    }
    
    private class func pedersen(_ values: [Felt]) throws -> Felt {
        return try values.reduce(Felt(0)!) { (previous, current) in
            return try pedersen(first: previous, second: current)
        }
    }
    
    public class func pedersenOn(elements: [Felt]) throws -> Felt {
        return try pedersen(first: pedersen(elements), second: Felt(BigUInt(elements.count))!)
    }
    
    public class func pedersenOn(elements: Felt...) throws -> Felt {
        let elementsArray = Array(elements)
        return try pedersenOn(elements: elementsArray)
    }
    
    public class func getPublicKey(privateKey: Felt) throws -> Felt {
        let publicKey = try CryptoCpp.getPublicKey(privateKey: privateKey.toData())
        
        if let publicKeyFelt = publicKey.toFelt() {
            return publicKeyFelt
        } else {
            throw StarknetCurveError.deserializationError
        }
    }
    
    public class func verify(publicKey: Felt, hash: Felt, r: Felt, s: Felt) throws -> Bool {
        guard let w = s.value.inverse(curveOrder) else {
            throw StarknetCurveError.verifyError
        }
        
        return try CryptoCpp.verify(publicKey: publicKey.toData(), hash: hash.toData(), r: r.toData(), s: w.toData())
    }
}

fileprivate extension Felt {
    func toData() -> Data {
        return self.value.toData()
    }
}

fileprivate extension BigUInt {
    func toData() -> Data {
        var data = self.serialize()
        
        data.reverse()
        data.padRight(toLength: 32)
        
        return data
    }
}

fileprivate extension Data {
    mutating func padRight(toLength length: Int, withPad pad: UInt8 = 0) {
        let paddingLength = length - self.count
        
        if paddingLength > 0 {
            self.append(contentsOf: [UInt8](repeating: pad, count: paddingLength))
        }
    }
    
    func toFelt() -> Felt? {
        var dataCopy = self
        dataCopy.reverse()
        return Felt(dataCopy)
    }
}
