//
//  DevnetClientModels.swift
//  
//
//  Created by Bartosz Rybarski on 08/02/2023.
//

import Foundation
import Starknet
import BigInt

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

struct TransactionResult {
    let address: Felt
    let hash: Felt
}

struct DeployAccountResult {
    let details: AccountDetails
    let txHash: Felt
}

struct PrefundPayload: Codable {
    let address: Felt
    let amount: UInt64
}

struct TransactionStatusResponse: Codable {
    let status: String // Once TransactionReceipts are added, replace with transaction status enum.
}

enum DevnetClientError: Error {
    case invalidTestPlatform
    case devnetEnvironmentVariableNotSet
    case devnetProcessError
    case portInUse
    case devnetProcessNotRunning
    case timeout
    case transactionRejected
    case deserializationError
}

