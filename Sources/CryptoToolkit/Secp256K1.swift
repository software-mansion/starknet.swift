import Foundation
import CSecp256K1


public class Secp256K1 {
    public static func getRfc6979Nonce(privateKey: Data, hash: Data, entropy: Data, attempt: UInt32) throws -> Data {
        var entropyCopy = entropy
        
        return try entropyCopy.withUnsafeMutableBytes { bytes in
            let (data, returnCode) = try runWithBufferOf(size: bufferByteSize) { buffer in
                return secp256k1_nonce_function_rfc6979(buffer, hash.toNative(), privateKey.toNative(), nil, bytes, attempt)
            }
            
            guard returnCode == 1 else {
                throw CryptoToolkitError.secp256K1Error
            }
            
            return data
        }
        
    }
}

private extension Data {
    func toNative() -> [UInt8] {
        return [UInt8](self)
    }
}
