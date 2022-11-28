import Foundation
import CCryptoCppWrapper
import CSecp256K1

public enum CryptoCppError: Error {
    case nativeError
}

public class CryptoCpp {
    private static let bufferByteSize = 32
    
    private class func runWithBuffer(ofSize bufferSize: Int, body: (_ buffer: UnsafeMutablePointer<CChar>) -> Int32) throws -> Data {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        
        let result = body(buffer)
        guard result == 0 else {
            throw CryptoCppError.nativeError
        }
        
        var output = Data()
        return buffer.withMemoryRebound(to: UInt8.self, capacity: bufferSize) { (pointer: UnsafeMutablePointer<UInt8>) in
            output.append(pointer, count: bufferSize)
            return output
        }
    }
    
    public static func pedersen(first: Data, second: Data) throws -> Data {
        return try runWithBuffer(ofSize: bufferByteSize) { buffer in
            return Hash(first.toNative(), second.toNative(), buffer)
        }
    }
    
    public class func sign(privateKey: Data, hash: Data, k: Data) throws -> Data {
        return try runWithBuffer(ofSize: 2 * bufferByteSize) { buffer in
            return Sign(privateKey.toNative(), hash.toNative(), k.toNative(), buffer)
        }
    }
    
    public class func getPublicKey(privateKey: Data) throws -> Data {
        return try runWithBuffer(ofSize: bufferByteSize) { buffer in
            return GetPublicKey(privateKey.toNative(), buffer)
        }
    }
    
    public class func verify(publicKey: Data, hash: Data, r: Data, s: Data) throws -> Bool {
        let result = Verify(publicKey.toNative(), hash.toNative(), r.toNative(), s.toNative())
        
        guard result >= 0 else {
            throw CryptoCppError.nativeError
        }
        
        return result == 0 ? false : true
    }
    
    public class func getNonce(privateKey: Data, hash: Data, attempt: UInt32) throws -> Data {
        return try runWithBuffer(ofSize: bufferByteSize) { buffer in
            return secp256k1_nonce_function_rfc6979(buffer, [UInt8](hash), [UInt8](privateKey), nil, nil, attempt)
        }
    }
}

private extension Data {
    func toNative() -> [CChar] {
        return [UInt8](self).map { Int8(bitPattern: $0) }  as [CChar]
    }
    
    mutating func padRight(toLength length: Int, withPad pad: UInt8) {
        let paddingLength = length - self.count
        
        if paddingLength > 0 {
            self.append(contentsOf: [UInt8](repeating: pad, count: paddingLength))
        }
    }
}
