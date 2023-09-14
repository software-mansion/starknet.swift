import BigInt
import Foundation
import Starknet

struct AccountDeploySnCastResponse: SnCastResponse {
    let command: SnCastCommand = .accountDeploy
    let error: String? = nil
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

struct AccountCreateSnCastResponse: SnCastResponse {
    let command: SnCastCommand = .accountCreate
    let error: String? = nil
    let accountAddress: Felt
    let maxFee: Felt

    enum CodingKeys: String, CodingKey {
        case accountAddress = "address"
        case maxFee = "max_fee"
    }
}

struct DeclareSnCastResponse: SnCastResponse {
    let command: SnCastCommand = .declare
    let error: String? = nil
    let classHash: Felt
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case classHash = "class_hash"
        case transactionHash = "transaction_hash"
    }
}

struct DeploySnCastResponse: SnCastResponse {
    let command: SnCastCommand = .deploy
    let error: String? = nil
    let contractAddress: Felt
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case transactionHash = "transaction_hash"
    }
}

protocol SnCastResponse: Decodable {
    var command: SnCastCommand { get }
    var error: String? { get }
}

public enum SnCastError: Error {
    case snCastError(String)
    case commandError(String)
    case invalidResponseJson
}
