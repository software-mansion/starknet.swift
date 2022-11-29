import Foundation

internal func runWithBufferOf(size bufferSize: Int, body: (_ buffer: UnsafeMutablePointer<CChar>) -> Int32) throws -> (data: Data, returnCode: Int32) {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
    defer {
        buffer.deallocate()
    }
    
    let returnCode = body(buffer)
    
    var output = Data()
    return buffer.withMemoryRebound(to: UInt8.self, capacity: bufferSize) { (pointer: UnsafeMutablePointer<UInt8>) in
        output.append(pointer, count: bufferSize)
        return (output, returnCode)
    }
}

internal let bufferByteSize = 32

public enum CryptoToolkitError: Error {
    case cryptoCppError
    case secp256K1Error
}

internal extension Data {
    func paddedLeftUpTo(_ length: Int) -> Data {
        let paddingLength = length - self.count
        
        if paddingLength > 0 {
            return Data(repeating: 0, count: paddingLength) + self
        }
        
        return self
    }
}
