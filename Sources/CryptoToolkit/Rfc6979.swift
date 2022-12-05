import Foundation
import CCryptopp

public class Rfc6979 {
    public static func getRfc6979Nonce(privateKey: Data, curveOrder: Data, hash: Data, attempt: Int32) throws -> Data {
        let (data, returnCode) = try runWithBufferOf(size: bufferByteSize) { buffer in
            return generate_rfc6979_k(privateKey.toNative(), curveOrder.toNative(), hash.toNative(), attempt, buffer)
        }
        
        guard returnCode == 0 else {
            throw CryptoToolkitError.secp256K1Error
        }
        
        return data
        
    }
}

private extension Data {
    func toNative() -> [UInt8] {
        return [UInt8](self)
    }
}
