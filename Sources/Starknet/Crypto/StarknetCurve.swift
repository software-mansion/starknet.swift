import Foundation
import CryptoToolkit
import BigInt

enum StarknetCurveError: Error {
    case deserializationError
    case verifyError
    case unknownError
}

public class StarknetCurve {
    private static let curveOrder = BigUInt("800000000000010FFFFFFFFFFFFFFFFB781126DCAE7B2321E66A241ADC64D2F", radix: 16)!
    
    public class func pedersen(first: Felt, second: Felt) throws -> Felt {
        let result = try CryptoCpp.pedersen(first: first.serialize(), second: second.serialize())
        
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
        let publicKey = try CryptoCpp.getPublicKey(privateKey: privateKey.serialize())
        
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
        
        return try CryptoCpp.verify(publicKey: publicKey.serialize(), hash: hash.serialize(), r: r.serialize(), s: w.serialize())
    }
    
    internal class func sign(privateKey: Felt, hash: Felt, k: BigUInt) throws -> StarknetCurveSignature {
        let signatureData = try CryptoCpp.sign(privateKey: privateKey.serialize(), hash: hash.serialize(), k: k.serialize())
        
        guard let r = signatureData.subdata(in: 0..<32).toFelt(),
              let wInversed = signatureData.subdata(in: 32..<64).toBigUInt().inverse(curveOrder),
              let s = Felt(wInversed) else {
            throw StarknetCurveError.deserializationError
        }
        
        return StarknetCurveSignature(r: r, s: s)
    }
    
    public class func sign(privateKey: Felt, hash: Felt) throws -> StarknetCurveSignature {
        var lastError: Error? = nil
        
        for attempt: Int32 in 0..<3 {
            let k = try Rfc6979.getRfc6979Nonce(privateKey: privateKey.serialize(), curveOrder: curveOrder.serialize(), hash: hash.serialize(), attempt: attempt)
            
            let uint = k.toBigUInt()
            
            do {
                return try sign(privateKey: privateKey, hash: hash, k: k.toBigUInt())
            } catch let e {
                lastError = e
            }
        }
        
        if let lastError = lastError {
            throw lastError
        }
        
        throw StarknetCurveError.unknownError
    }
}

fileprivate extension Data {
    func toFelt() -> Felt? {
        return Felt(self)
    }
    
    func toBigUInt() -> BigUInt {
        return BigUInt(self)
    }
}
