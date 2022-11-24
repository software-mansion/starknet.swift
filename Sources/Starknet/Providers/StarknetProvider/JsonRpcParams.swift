import Foundation

struct CallParams: Encodable {
    let request: StarknetCall
    let blockId: StarknetBlockId
    
    enum CodingKeys: String, CodingKey {
        case request
        case blockId = "block_id"
    }
}
