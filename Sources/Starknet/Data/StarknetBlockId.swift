import Foundation

public enum StarknetBlockId: Equatable {
    public enum BlockTag: String, Codable {
        case l1Accepted = "l1_accepted"
        case latest
        case preConfirmed = "pre_confirmed"
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
            try blockTag.encode(to: encoder)
        }
    }
}
