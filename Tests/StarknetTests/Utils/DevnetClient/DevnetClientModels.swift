import BigInt
import Foundation
import Starknet

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
    let status: LegacyStarknetTransactionStatus?
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

        self.status = try container.decodeIfPresent(LegacyStarknetTransactionStatus.self, forKey: .status)
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
