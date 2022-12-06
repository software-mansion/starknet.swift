import Foundation
import CFrameworkWrapper

public class CryptoRs {
    public static func getRfc6979Nonce(hash: Data, privateKey: Data, seed: Data) throws -> Data {
        let (data, returnCode) = try runWithBufferOf(size: bufferByteSize) { buffer in
            return generate_k(hash.toNative(), privateKey.toNative(), seed.toNative(), buffer)
        }
            
        guard returnCode == 0 else {
            throw CryptoToolkitError.cryptoRsError
        }
        
        return data
    }
}

private extension Data {
    func toNative() -> [UInt8] {
        return [UInt8](self.paddingLeft(toLength: 32))
    }
}
