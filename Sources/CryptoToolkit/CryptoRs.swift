import Foundation
import CFrameworkWrapper

public class CryptoRs {
    public static func getRfc6979Nonce(hash: Data, privateKey: Data, seed: Data) throws -> Data {
        let data = runWithBuffer(resultSize: standardResultSize, expectedReturnCode: 0) { buffer in
            return generate_k(hash.toNative(), privateKey.toNative(), seed.toNative(), buffer)
        }
        
        guard let data = data else {
            throw CryptoToolkitError.nativeError
        }
        
        return data
    }
}

private extension Data {
    func toNative() -> [UInt8] {
        return [UInt8](self.paddingLeft(toLength: 32))
    }
}
