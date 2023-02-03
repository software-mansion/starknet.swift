import Foundation

struct JsonRpcPayload<T: Encodable>: Encodable {
    let version = "2.0"
    let id = 0

    let method: JsonRpcMethod
    let params: T

    init(method: JsonRpcMethod, params: T) {
        self.method = method
        self.params = params
    }

    enum CodingKeys: String, CodingKey {
        case version = "jsonrpc"
        case id
        case method
        case params
    }
}
