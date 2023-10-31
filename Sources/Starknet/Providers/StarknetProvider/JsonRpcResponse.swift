import Foundation

struct JsonRpcErrorData: Decodable {
    let revertError: String

    enum CodingKeys: String, CodingKey {
        case revertError = "revert_error"
    }
}

struct JsonRpcError: Decodable {
    let code: Int
    let message: String
    let data: JsonRpcErrorData?
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
