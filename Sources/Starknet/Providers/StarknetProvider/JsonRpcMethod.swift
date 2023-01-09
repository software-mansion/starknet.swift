import Foundation

enum JsonRpcMethod: String, Encodable {
    case call = "starknet_call"
    case getNonce = "starknet_getNonce"
    case invokeFunction = "starknet_addInvokeTransaction"
    case estimateFee = "starknet_estimateFee"
}
