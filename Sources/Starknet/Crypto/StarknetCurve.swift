import Foundation
import CryptoToolkit
import BigInt

public enum StarknetCurveError: Error {
    case deserializationError
    case invalidArgumentError
    case verifyError
    case unknownError
}

public class StarknetCurve {
    /// x coordinate of Starknet curve generator.
    public static let curveOrder = BigUInt("800000000000010FFFFFFFFFFFFFFFFB781126DCAE7B2321E66A241ADC64D2F", radix: 16)!
    
    /// Compute pedersen hash on input values.
    ///
    /// - Returns: Pedersen hash of the two values as Felt.
    public class func pedersen(first: Felt, second: Felt) -> Felt {
        let result = CryptoCpp.pedersen(first: first.serialize(), second: second.serialize())
        
        return Felt(result)!
    }
    
    private class func pedersen(_ values: [Felt]) -> Felt {
        return values.reduce(Felt(0)) { (previous, current) in
            return pedersen(first: previous, second: current)
        }
    }
    
    /// Compute pedersen hash on an array of input values.
    ///
    /// Compute pedersen hash on an array of input values, appended by length of the array.
    ///
    /// - Parameters:
    ///     - elements: array of felt values, used as input to Pedersen hash.
    /// - Returns: Pedersen hash on elements array and its length.
    public class func pedersenOn(elements: [Felt]) -> Felt {
        return pedersen(first: pedersen(elements), second: Felt(BigUInt(elements.count))!)
    }
    
    /// Compute pedersen hash on an array of input values passed as a variadic expression.
    ///
    /// Compute pedersen hash on an array of input values passed as a variadic expression, appended by length of the array.
    ///
    /// - Parameters:
    ///     - elements: series of felt values, used as input to Pedersen hash.
    /// - Returns: Pedersen hash on elements array and its length.
    public class func pedersenOn(elements: Felt...) -> Felt {
        let elementsArray = Array(elements)
        return pedersenOn(elements: elementsArray)
    }
    
    /// Compute Starknet public key for given private key.
    ///
    /// - Parameters:
    ///     - privateKey: starknet private key as Felt.
    /// - Returns: Public key as Felt.
    public class func getPublicKey(privateKey: Felt) throws -> Felt {
        guard privateKey != 0 else {
            throw StarknetCurveError.invalidArgumentError
        }
        
        let publicKey = try CryptoCpp.getPublicKey(privateKey: privateKey.serialize())
        
        return try publicKey.toFelt()
    }
    
    /// Verifiy Starknet signature.
    ///
    /// - Parameters:
    ///     - publicKey: public key used to verify a signature.
    ///     - hash: a value that was signed.
    ///     - r: part of the signature.
    ///     - s: part of the signature.
    public class func verify(publicKey: Felt, hash: Felt, r: Felt, s: Felt) throws -> Bool {
        guard let w = s.value.inverse(curveOrder) else {
            throw StarknetCurveError.verifyError
        }
        
        return CryptoCpp.verify(publicKey: publicKey.serialize(), hash: hash.serialize(), r: r.serialize(), s: w.serialize())
    }
    
    /// Sign hash with StarknetPrivate key and given k value.
    ///
    /// This method is internal, as using bad k parameter is very dangerous and may lead to exposing the private key.
    internal class func sign(privateKey: Felt, hash: Felt, k: BigUInt) throws -> StarknetCurveSignature {
        let signatureData = try CryptoCpp.sign(privateKey: privateKey.serialize(), hash: hash.serialize(), k: k.serialize())
        
        let r = try signatureData.subdata(in: 0..<32).toFelt()
        
        guard let wInversed = signatureData.subdata(in: 32..<64).toBigUInt().inverse(curveOrder),
              let s = Felt(wInversed) else {
            throw StarknetCurveError.deserializationError
        }
        
        return StarknetCurveSignature(r: r, s: s)
    }
        
    /// Sign hash with Starknet private key.
    ///
    /// Sign hash with provided Starknet private key. It deterministically generates k value, as described in RFC6979 section 3.2.
    ///
    /// - Parameters:
    ///     - privateKey: private key used to sign a hash.
    ///     - hash: a value to be signed.
    /// - Returns: StarknetCurveSignature, as an array of r and s values.
    public class func sign(privateKey: Felt, hash: Felt) throws -> StarknetCurveSignature {
        var lastError: Error? = nil
        
        var salt = BigUInt.zero
        
        for _: Int32 in 0..<3 {
            // Generate k according to RFC6979, section 3.2. Generated k may not be suitable for signing,
            // so it might have to be calculated again. Probability of this is, however, very low.
            let k = try CryptoRs.getRfc6979Nonce(hash: hash.serialize(), privateKey: privateKey.serialize(), seed: salt.serialize())
            
            do {
                return try sign(privateKey: privateKey, hash: hash, k: k.toBigUInt())
            } catch let e {
                lastError = e
            }
            
            salt += 1
        }
        
        if let lastError = lastError {
            throw lastError
        }
        
        throw StarknetCurveError.unknownError
    }
}

fileprivate extension Data {
    func toFelt() throws -> Felt {
        if let feltValue = Felt(self) {
            return feltValue
        } else {
            throw StarknetCurveError.deserializationError
        }
    }
    
    func toBigUInt() -> BigUInt {
        return BigUInt(self)
    }
}
