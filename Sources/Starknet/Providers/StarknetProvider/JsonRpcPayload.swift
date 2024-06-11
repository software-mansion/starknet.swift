import Foundation

struct JsonRpcPayload: Encodable {
    let version = "2.0"
    let id: Int

    let method: JsonRpcMethod
    let params: JsonRpcParams

    init(method: JsonRpcMethod, params: JsonRpcParams, id: Int = 0) {
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
