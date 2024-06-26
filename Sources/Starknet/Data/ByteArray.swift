import Foundation

private let shortStringMaxLen = 31

/// Represents a ByteArray struct from Cairo.
///
/// The ByteArray struct is used to represent a string in Cairo.
///
/// - Parameters:
///  - data: list of 31-byte chunks of the byte array
///  - pendingWord: the last chunk of the byte array, which consists of at most 30 bytes
///  - pendingWordLen: the number of bytes in `pendingWord`
public struct StarknetByteArray: Equatable, Hashable, ExpressibleByStringLiteral {
    let data: [Felt]
    let pendingWord: Felt
    let pendingWordLen: Int

    public init?(data: [Felt], pendingWord: Felt, pendingWordLen: Int) {
        self.data = data
        self.pendingWord = pendingWord
        self.pendingWordLen = pendingWordLen

        guard self.data.allSatisfy({ $0.byteWidth == shortStringMaxLen }),
              self.pendingWordLen >= 0,
              self.pendingWordLen < shortStringMaxLen,
              self.pendingWord.byteWidth == self.pendingWordLen
        else {
            return nil
        }
    }

    public init(fromString string: String) {
        let shortStrings = string.splitToShortStrings()
        let encodedShortStrings = shortStrings.map { Felt.fromShortString($0)! }

        if shortStrings.isEmpty || shortStrings.last!.count == shortStringMaxLen {
            self.data = encodedShortStrings
            self.pendingWord = .zero
            self.pendingWordLen = 0
        } else {
            self.data = encodedShortStrings.dropLast()
            self.pendingWord = encodedShortStrings.last!
            self.pendingWordLen = shortStrings.last!.count
        }
    }
}

public extension StarknetByteArray {
    typealias StringLiteralType = String

    init(stringLiteral value: String) {
        self.init(fromString: value)
    }
}

private extension Felt {
    var byteWidth: Int {
        (value.bitWidth + 7) / 8
    }
}
