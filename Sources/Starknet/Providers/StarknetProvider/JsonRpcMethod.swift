import Foundation

enum JsonRpcMethod: String, Encodable {
    case call = "starknet_call"
    case invokeFunction = "starknet_addInvokeTransaction"
}
