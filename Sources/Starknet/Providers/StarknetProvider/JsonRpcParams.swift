import Foundation

struct CallParams: Encodable {
    let request: Call
    let blockId: BlockId
    
    enum CodingKeys: String, CodingKey {
        case request
        case blockId = "block_id"
    }
}
