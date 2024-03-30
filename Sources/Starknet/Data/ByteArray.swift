import Foundation

public struct StarknetByteArray: Equatable, Hashable, ExpressibleByStringLiteral {
    let data: [Felt]
    let pendingWord: Felt
    let pendingWordLen: Int

    public init?(data: [Felt], pendingWord: Felt, pendingWordLen: Int) {
        self.data = data
        self.pendingWord = pendingWord
        self.pendingWordLen = pendingWordLen

        guard self.data.allSatisfy({ $0.byteWidth == 31 }),
              self.pendingWordLen >= 0,
              self.pendingWordLen < 31,
              self.pendingWord.byteWidth == self.pendingWordLen
        else {
            return nil
        }
    }

    public init(fromString: String) {
        let shortStrings = fromString.splitToShortStrings()
        let encodedShortStrings = shortStrings.map { Felt.fromShortString($0)! }

        if shortStrings.isEmpty || shortStrings.last!.count == 31 {
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
