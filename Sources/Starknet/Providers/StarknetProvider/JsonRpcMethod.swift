import Foundation

enum JsonRpcMethod: String, Encodable {
    case call = "starknet_call"
    case getNonce = "starknet_getNonce"
    case invokeFunction = "starknet_addInvokeTransaction"
    case deployAccount = "starknet_addDeployAccountTransaction"
    case estimateFee = "starknet_estimateFee"
    case getClassHashAt = "starknet_getClassHashAt"
    case getBlockNumber = "starknet_blockNumber"
    case getBlockHashAndNumber = "starknet_blockHashAndNumber"
    case getEvents = "starknet_getEvents"
    case getTransactionByHash = "starknet_getTransactionByHash"
    case getTransactionByBlockIdAndIndex = "starknet_getTransactionByBlockIdAndIndex"
    case getTransactionReceipt = "starknet_getTransactionReceipt"
    case simulateTransaction = "starknet_simulateTransaction"
    case estimateMessageFee = "starknet_estimateMessageFee"
}
