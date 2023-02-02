import Foundation

struct JsonRpcError: Decodable {
    let code: Int
    let message: String
}

struct JsonRpcResponse<T: Decodable>: Decodable {
    let id: Int
    let jsonRpc: String

    let result: T?
    let error: JsonRpcError?

    enum CodingKeys: String, CodingKey {
        case id
        case jsonRpc = "jsonrpc"
        case result
        case error
    }
}
