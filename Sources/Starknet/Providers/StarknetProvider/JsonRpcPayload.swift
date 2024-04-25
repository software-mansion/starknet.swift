import Foundation

struct JsonRpcPayload<T: Encodable>: Encodable {
    let version = "2.0"
    var id: Int

    let method: JsonRpcMethod
    let params: T

    init(method: JsonRpcMethod, params: T, id: Int = 0) {
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
