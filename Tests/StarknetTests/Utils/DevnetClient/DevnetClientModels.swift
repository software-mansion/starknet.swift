import BigInt
import Foundation
import Starknet

enum DevnetClientConstants {
    // Source: https://github.com/0xSpaceShard/starknet-devnet-rs/blob/323f907bc3e3e4dc66b403ec6f8b58744e8d6f9a/crates/starknet/src/constants.rs
    static let accountContractClassHash: Felt = "0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f"
    static let erc20ContractClassHash: Felt = "0x6a22bf63c7bc07effa39a25dfbd21523d211db0100a0afd054d172b81840eaf"
    static let ethErc20ContractAddress: Felt = "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    static let strkErc20ContractAddress: Felt = "0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d"
    static let udcContractClassHash: Felt = "0x7b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69"
    static let udcContractAddress: Felt = "0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf"
    // Source: starknet-devnet-rs cli
    // Only for seed 1_053_545_547
    static let predeployedAccount1: AccountDetails = .init(privateKey: "0x0000000000000000000000000000000069bbdd410db5a6f817e5fae1bf3191b3", publicKey: "0x00d576e1ba0ffd7963507ddfd08b5fd967046fd5eafca4a668d73c60b17ebb6d", address: "0x00a97c3906ca442b26b68f9b510ee15c4a6994764de828a1b5dc04fe7f717063", salt: 20)
    static let predeployedAccount2: AccountDetails = .init(privateKey: "0x0000000000000000000000000000000088ca21b05b8765f9654c171f65b2327c", publicKey: "0x07693c6c6672c19d2d3a20dbec30758d40ac1ea3e536defedc68764ba8234ed0", address: "0x051ff12b24abce0508e5dfde92be06aade5c59fcae29dd11c6076a6cced3c434", salt: 20)
}

struct AccountDetails: Codable {
    let privateKey: Felt
    let publicKey: Felt
    let address: Felt
    let salt: Felt

    enum CodingKeys: String, CodingKey {
        case privateKey = "private_key"
        case publicKey = "public_key"
        case address
        case salt
    }

    init(privateKey: Felt, publicKey: Felt, address: Felt, salt: Felt) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.address = address
        self.salt = salt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.privateKey = try container.decode(Felt.self, forKey: .privateKey)
        self.publicKey = try container.decode(Felt.self, forKey: .publicKey)
        self.address = try container.decode(Felt.self, forKey: .address)
        self.salt = try container.decode(Felt.self, forKey: .salt)
    }
}

struct DeployAccountResult {
    let details: AccountDetails
    let transactionHash: Felt
}

struct CreateAccountResult {
    let name: String
    let details: AccountDetails
}

struct DeclareContractResult {
    let classHash: Felt
    let transactionHash: Felt
}

struct DeployContractResult {
    let contractAddress: Felt
    let transactionHash: Felt
}

struct DeclareDeployContractResult {
    let declare: DeclareContractResult
    let deploy: DeployContractResult
}

struct InvokeContractResult {
    let transactionHash: Felt
}

// TODO(#209): Once we can use UInt128, we should change type of `amount`` to UInt128
// and remove coding keys and `encode` method (they won't be needed).

struct PrefundPayload: Codable {
    let address: Felt
    let amount: UInt128AsHex
    let unit: StarknetPriceUnit

    enum CodingKeys: String, CodingKey {
        case address
        case amount
        case unit
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(amount.value.description, forKey: .amount)
        try container.encode(unit, forKey: .unit)
    }
}

// Simplified receipt that is intended to support any JSON-RPC version starting 0.3,
// to avoid DevnetClient relying on StarknetTransactionReceipt.
// Only use it for checking whether a transaction was successful.
struct DevnetReceipt: Decodable {
    let status: StarknetTransactionStatus?
    let executionStatus: StarknetTransactionExecutionStatus?
    let finalityStatus: StarknetTransactionFinalityStatus?

    enum CodingKeys: String, CodingKey {
        case status
        case executionStatus = "execution_status"
        case finalityStatus = "finality_status"
    }

    public var isSuccessful: Bool {
        switch status {
        case nil:
            executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
        default:
            status == .acceptedL1 || status == .acceptedL2
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.status = try container.decodeIfPresent(StarknetTransactionStatus.self, forKey: .status)
        self.executionStatus = try container.decodeIfPresent(StarknetTransactionExecutionStatus.self, forKey: .executionStatus)
        self.finalityStatus = try container.decodeIfPresent(StarknetTransactionFinalityStatus.self, forKey: .finalityStatus)

        guard status != nil || (executionStatus != nil && finalityStatus != nil) else {
            throw DevnetClientError.unknownTransactionStatus
        }
    }
}

public enum DevnetClientError: Error {
    case invalidTestPlatform
    case environmentVariablesNotSet
    case devnetError
    case startupError
    case snCastError(String)
    case jsonRpcError(Int, String)
    case portAlreadyInUse
    case devnetNotRunning
    case timeout
    case transactionFailed
    case transactionSucceeded
    case unknownTransactionStatus
    case prefundError
    case networkProviderError
    case deserializationError
    case missingResourceFile
    case fileManagerError
    case accountNotFound
}
