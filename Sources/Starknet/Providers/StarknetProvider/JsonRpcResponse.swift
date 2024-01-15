import Foundation

struct JsonRpcError: Decodable {
    let code: Int
    let message: String
    let data: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)

        do {
            let anyDecodable = try container.decode(AnyDecodable.self, forKey: .data)
            if anyDecodable.value is String {
                data = anyDecodable.value as? String
            } else {
                let jsonData = try JSONSerialization.data(withJSONObject: anyDecodable.value)
                data = String(data: jsonData, encoding: .utf8)
            }
        } catch {
            data = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
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

private struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map(\.value)
        } else if let dictionaryValue = try? container.decode([String: AnyDecodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyDecodable.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
