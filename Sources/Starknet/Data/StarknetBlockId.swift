import Foundation

public enum StarknetBlockId: Equatable {
    public enum BlockTag: String {
        case latest
        case preConfirmed
    }

    case hash(Felt)
    case number(Int)
    case tag(BlockTag)

    enum CodingKeys: String, CodingKey {
        case latest
        case preConfirmed = "pre_confirmed"
    }
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
