import Foundation

public enum StarknetBlockId {
    public enum BlockTag: String {
        case latest
        case pending
    }

    case hash(Felt)
    case number(Int)
    case tag(BlockTag)
}

extension StarknetBlockId: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .hash(feltValue):
            let dict = [
                "block_hash": feltValue.toHex(),
            ]
            try dict.encode(to: encoder)
        case let .number(intValue):
            let dict = [
                "block_number": intValue,
            ]
            try dict.encode(to: encoder)
        case let .tag(blockTag):
            try blockTag.rawValue.encode(to: encoder)
        }
    }
}
