import Foundation

public enum BlockId {
    public enum BlockTag: String {
        case latest
        case pending
    }
    
    case hash(Felt)
    case number(Int)
    case tag(BlockTag)
}
