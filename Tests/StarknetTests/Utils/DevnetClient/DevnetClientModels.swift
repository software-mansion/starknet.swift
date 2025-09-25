import BigInt
import Foundation
import Starknet

enum DevnetClientConstants {
    // Source: https://github.com/0xSpaceShard/starknet-devnet/blob/430b3370e60b28b8de430143b26e52bf36380b9a/crates/starknet-devnet-core/src/constants.rs#L25
    static let accountContractClassHash: Felt = "0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564"
    static let ethErc20ContractAddress: Felt = "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    // Source: starknet-devnet-rs cli
    // Only for seed 1_053_545_547
    static let predeployedAccount1: AccountDetails = .init(privateKey: "0x00000000000000000000000000000000a2ed22bb0cb0b49c69f6d6a8d24bc5ea", publicKey: "0x0198e98e771ebb5da7f4f05658a80a3d6be2213dc5096d055cbbefa62901ab06", address: "0x01323cacbc02b4aaed9bb6b24d121fb712d8946376040990f2f2fa0dcf17bb5b", salt: 20)
    static let predeployedAccount2: AccountDetails = .init(privateKey: "0x00000000000000000000000000000000c1c7db92d22ef773de96f8bde8e56c85", publicKey: "0x026df62f8e61920575f9c9391ed5f08397cfcfd2ade02d47781a4a8836c091fd", address: "0x034864aab9f693157f88f2213ffdaa7303a46bbea92b702416a648c3d0e42f35", salt: 20)
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

// TODO(#209): Once we can use UInt128, we should change type of `amount` to UInt128
// and remove coding keys and `encode` method (they won't be needed).

struct PrefundPayload: Codable {
    let address: Felt
    let amount: BigUInt
    let unit: StarknetPriceUnit

    enum CodingKeys: String, CodingKey {
        case address
        case amount
        case unit
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(amount.description, forKey: .amount)
        try container.encode(unit, forKey: .unit)
    }
}

struct DevnetMintRequest: Codable {
    let jsonrpc: String
    let method: String
    let params: PrefundPayload
    let id: Int

    init(params: PrefundPayload, id: Int = 0) {
        self.jsonrpc = "2.0"
        self.method = "devnet_mint"
        self.params = params
        self.id = id
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
