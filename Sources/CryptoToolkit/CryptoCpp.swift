import Foundation
import CFrameworkWrapper

public class CryptoCpp {
    private static func internalRunWithBufferOf(size: Int, _ body: (UnsafeMutablePointer<CChar>) -> Int32) throws -> Data {
        let (data, returnCode) = try runWithBufferOf(size: size, body: body)
        
        guard returnCode == 0 else {
            throw CryptoToolkitError.cryptoCppError
        }
        
        return data
    }
    
    public static func pedersen(first: Data, second: Data) throws -> Data {
        let result =  try internalRunWithBufferOf(size: bufferByteSize) { buffer in
            return Hash(first.toNative(), second.toNative(), buffer)
        }
        
        return result.fromNative()
    }
    
    public class func sign(privateKey: Data, hash: Data, k: Data) throws -> Data {
        let result = try internalRunWithBufferOf(size: 2 * bufferByteSize) { buffer in
            return Sign(privateKey.toNative(), hash.toNative(), k.toNative(), buffer)
        }
        
        let first = result.subdata(in: 0..<bufferByteSize)
        let second = result.subdata(in: bufferByteSize..<(2 * bufferByteSize))
        
        return first.fromNative() + second.fromNative()
    }
    
    public class func getPublicKey(privateKey: Data) throws -> Data {
        let result = try internalRunWithBufferOf(size: bufferByteSize) { buffer in
            return GetPublicKey(privateKey.toNative(), buffer)
        }
        
        return result.fromNative()
    }
    
    public class func verify(publicKey: Data, hash: Data, r: Data, s: Data) throws -> Bool {
        let result = Verify(publicKey.toNative(), hash.toNative(), r.toNative(), s.toNative())
        
        guard result >= 0 else {
            throw CryptoToolkitError.cryptoCppError
        }
        
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
