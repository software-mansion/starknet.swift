import BigInt
import Foundation
import Starknet

enum DevnetClientConstants {
    // Source: https://github.com/0xSpaceShard/starknet-devnet-rs/blob/323f907bc3e3e4dc66b403ec6f8b58744e8d6f9a/crates/starknet/src/constants.rs
    static let accountContractClassHash: Felt = "0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f"
    static let erc20ContractClassHash: Felt = "0x6a22bf63c7bc07effa39a25dfbd21523d211db0100a0afd054d172b81840eaf"
    static let erc20ContractAddress: Felt = "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    static let udcContractClassHash: Felt = "0x7b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69"
    static let udcContractAddress: Felt = "0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf"
    // Source: starknet-devnet-rs cli
    // Only for seed 1_053_545_547
    static let predeployedAccount1: AccountDetails = .init(privateKey: "0xa2ed22bb0cb0b49c69f6d6a8d24bc5ea", publicKey: "0x198e98e771ebb5da7f4f05658a80a3d6be2213dc5096d055cbbefa62901ab06", address: "0x1323cacbc02b4aaed9bb6b24d121fb712d8946376040990f2f2fa0dcf17bb5b", salt: 20)
    static let predeployedAccount2: AccountDetails = .init(privateKey: "0xc1c7db92d22ef773de96f8bde8e56c85", publicKey: "0x26df62f8e61920575f9c9391ed5f08397cfcfd2ade02d47781a4a8836c091fd", address: "0x34864aab9f693157f88f2213ffdaa7303a46bbea92b702416a648c3d0e42f35", salt: 20)
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
    let maxFee: Felt
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

struct PrefundPayload: Codable {
    let address: Felt
    let amount: UInt64
}

// Simplified receipt that is intended to support any JSON-RPC version starting 0.3,
// to avoid DevnetClient relying on StarknetTransactionReceipt.
// Only use it for checking whether a transaction was successful.
struct DevnetReceipt: Decodable {
    let status: StarknetGatewayTransactionStatus?
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
            return executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
        default:
            return status == .acceptedL1 || status == .acceptedL2
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.status = try container.decodeIfPresent(StarknetGatewayTransactionStatus.self, forKey: .status)
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
