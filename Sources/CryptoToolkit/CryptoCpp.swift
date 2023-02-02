import Foundation
import CFrameworkWrapper

public class CryptoCpp {
    public static func pedersen(first: Data, second: Data) -> Data {
        let result = runWithBuffer(resultSize: standardResultSize, expectedReturnCode: 0) { buffer in
            return Hash(first.toNative(), second.toNative(), buffer)
        }
       
        return result!.fromNative()
    }
    
    public class func sign(privateKey: Data, hash: Data, k: Data) throws -> Data {
        let result = runWithBuffer(resultSize: 2 * standardResultSize, expectedReturnCode: 0) { buffer in
            return Sign(privateKey.toNative(), hash.toNative(), k.toNative(), buffer)
        }
        
        guard let result = result else { throw CryptoToolkitError.nativeError }
        
        let first = result.subdata(in: 0..<standardResultSize)
        let second = result.subdata(in: standardResultSize..<(2 * standardResultSize))
        
        return first.fromNative() + second.fromNative()
    }
    
    public class func getPublicKey(privateKey: Data) throws -> Data {
        let result = runWithBuffer(resultSize: standardResultSize, expectedReturnCode: 0) { buffer in
            return GetPublicKey(privateKey.toNative(), buffer)
        }
        
        guard let result = result else { throw CryptoToolkitError.nativeError }

        return result.fromNative()
    }
    
    public class func verify(publicKey: Data, hash: Data, r: Data, s: Data) -> Bool {
        let result = Verify(publicKey.toNative(), hash.toNative(), r.toNative(), s.toNative())
        
        return result == 1
    }
}

private extension Data {
    // Note, crypto-cpp accepts and returns bytes in little-endian order.
    
    func toNative() -> [CChar] {
        let reversed = Data(self.paddingLeft(toLength: 32).reversed())
        
        return [UInt8](reversed).map { Int8(bitPattern: $0) } as [CChar]
    }
    
    func fromNative() -> Data {
        return Data(self.reversed())
    }
}
