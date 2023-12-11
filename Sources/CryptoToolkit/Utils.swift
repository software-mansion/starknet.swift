import Foundation

func runWithBuffer(resultSize: Int, expectedReturnCode: Int, body: (_ buffer: UnsafeMutablePointer<CChar>) -> Int32) -> Data? {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: outBufferSize)
    defer {
        buffer.deallocate()
    }

    let returnCode = body(buffer)

    guard returnCode == expectedReturnCode else {
        return nil
    }

    var output = Data()
    return buffer.withMemoryRebound(to: UInt8.self, capacity: resultSize) { (pointer: UnsafeMutablePointer<UInt8>) in
        output.append(pointer, count: resultSize)
        return output
    }
}

private let outBufferSize = 1024
let standardResultSize = 32

extension Data {
    func paddingLeft(toLength length: Int) -> Data {
        let paddingLength = length - self.count

        if paddingLength > 0 {
            return Data(repeating: 0, count: paddingLength) + self
        }

        return self
    }
}
