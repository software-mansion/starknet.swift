import Foundation

public struct StarknetCommonTransactionReceipt: StarknetTransactionReceipt, Decodable {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let status: StarknetTransactionStatus
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let type: StarknetTransactionType
    public let messagesSent: [MessageToL1]
    public let events: [StarknetEvent]

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case status
        case type
        case events
    }
}

public struct StarknetDeployTransactionReceipt: StarknetTransactionReceipt, Decodable {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let status: StarknetTransactionStatus
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let type: StarknetTransactionType
    public let messagesSent: [MessageToL1]
    public let events: [StarknetEvent]
    public let contractAddress: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case contractAddress = "contract_address"
        case status
        case type
        case events
    }
}

public protocol StarknetTransactionReceipt: Decodable {}
