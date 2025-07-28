public enum BlockStatus: String, Codable {
    case preConfirmed = "PRE_CONFIRMED"
    case acceptedOnL1 = "ACCEPTED_ON_L1"
    case acceptedOnL2 = "ACCEPTED_ON_L2"
    case rejected = "REJECTED"
}

public protocol StarknetBlock: Codable {
    var timestamp: Int { get }
    var sequencerAddress: Felt { get }
    var blockNumber: Int { get }
    var l1GasPrice: StarknetResourcePrice { get }
    var l2GasPrice: StarknetResourcePrice { get }
    var l1DataGasPrice: StarknetResourcePrice { get }
    var l1DataAvailabilityMode: StarknetL1DAMode { get }
    var starknetVersion: String { get }
}

public protocol StarknetProcessedBlock: StarknetBlock {
    var status: BlockStatus { get }
    var blockHash: Felt { get }
    var parentHash: Felt { get }
    var newRoot: Felt { get }
}

public protocol StarknetPreConfirmedBlock: StarknetBlock {}

public protocol StarknetBlockWithTxs: StarknetBlock {
    var transactions: [TransactionWrapper] { get }
}

public struct StarknetProcessedBlockWithTxs: StarknetProcessedBlock, StarknetBlockWithTxs, Encodable {
    public let status: BlockStatus
    public let transactions: [TransactionWrapper]
    public let blockHash: Felt
    public let parentHash: Felt
    public let blockNumber: Int
    public let newRoot: Felt
    public let timestamp: Int
    public let sequencerAddress: Felt
    public let l1GasPrice: StarknetResourcePrice
    public let l2GasPrice: StarknetResourcePrice
    public let l1DataGasPrice: StarknetResourcePrice
    public let l1DataAvailabilityMode: StarknetL1DAMode
    public let starknetVersion: String

    enum CodingKeys: String, CodingKey {
        case status
        case transactions
        case blockHash = "block_hash"
        case parentHash = "parent_hash"
        case blockNumber = "block_number"
        case newRoot = "new_root"
        case timestamp
        case sequencerAddress = "sequencer_address"
        case l1GasPrice = "l1_gas_price"
        case l2GasPrice = "l2_gas_price"
        case l1DataGasPrice = "l1_data_gas_price"
        case l1DataAvailabilityMode = "l1_da_mode"
        case starknetVersion = "starknet_version"
    }
}

public struct StarknetPreConfirmedBlockWithTxs: StarknetPreConfirmedBlock, StarknetBlockWithTxs, Codable {
    public let transactions: [TransactionWrapper]
    public let blockNumber: Int
    public let timestamp: Int
    public let sequencerAddress: Felt
    public let l1GasPrice: StarknetResourcePrice
    public let l2GasPrice: StarknetResourcePrice
    public let l1DataGasPrice: StarknetResourcePrice
    public let l1DataAvailabilityMode: StarknetL1DAMode
    public let starknetVersion: String

    enum CodingKeys: String, CodingKey {
        case transactions
        case blockNumber = "block_number"
        case timestamp
        case sequencerAddress = "sequencer_address"
        case l1GasPrice = "l1_gas_price"
        case l2GasPrice = "l2_gas_price"
        case l1DataGasPrice = "l1_data_gas_price"
        case l1DataAvailabilityMode = "l1_da_mode"
        case starknetVersion = "starknet_version"
    }
}

public enum StarknetBlockWithTxsWrapper: Codable {
    case processed(StarknetProcessedBlockWithTxs)
    case preConfirmed(StarknetPreConfirmedBlockWithTxs)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.parentHash) {
            let block = try StarknetProcessedBlockWithTxs(from: decoder)
            self = .processed(block)
        } else {
            let block = try StarknetPreConfirmedBlockWithTxs(from: decoder)
            self = .preConfirmed(block)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .processed(block): try block.encode(to: encoder)
        case let .preConfirmed(block): try block.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case parentHash = "parent_hash"
    }
}
