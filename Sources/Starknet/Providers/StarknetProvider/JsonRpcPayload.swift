import Foundation

struct JsonRpcPayload: Encodable {
    let version = "2.0"
    let id: Int

    let method: JsonRpcMethod
    let params: EncodableParams

    init(method: JsonRpcMethod, params: EncodableParams, id: Int = 0) {
        self.method = method
        self.params = params
        self.id = id
    }

    enum CodingKeys: String, CodingKey {
        case version = "jsonrpc"
        case id
        case method
        case params
    }
}
