import BigInt
import Foundation

// Sending requests with invoke v0 transaction is not supported starting starknet 0.11
private let invokeVersion: Felt = .one

public struct StarknetSequencerInvokeTransaction: StarknetSequencerTransaction, Equatable {
    public let type: StarknetTransactionType = .invoke

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let version: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case senderAddress = "sender_address"
        case calldata
        case signature
        case maxFee = "max_fee"
        case nonce
    }

    private static func estimateVersion(_ version: Felt) -> Felt {
        Felt(BigUInt(2).power(128).advanced(by: BigInt(version.value)))!
    }

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, forFeeEstimation: Bool = false) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.version = forFeeEstimation ? StarknetSequencerInvokeTransaction.estimateVersion(invokeVersion) : invokeVersion
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.version = try container.decode(Felt.self, forKey: .version)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetSequencerDeployAccountTransaction: StarknetSequencerTransaction, Equatable {
    public let type: StarknetTransactionType = .deployAccount

    public let version: Felt

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public init(signature: StarknetSignature, maxFee: Felt, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, version: Felt) {
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.version = version
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.version = try container.decode(Felt.self, forKey: .version)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case signature
        case maxFee = "max_fee"
        case nonce
        case contractAddressSalt = "contract_address_salt"
        case constructorCalldata = "constructor_calldata"
        case classHash = "class_hash"
    }
}

// Default deserializer doesn't check if the fields with default values match what is deserialized.
// It's an extension that resolves this.
extension StarknetSequencerTransaction {
    func verifyTransactionType<T>(container: KeyedDecodingContainer<T>, codingKeysType _: T.Type) throws where T: CodingKey {
        let type = try container.decode(StarknetTransactionType.self, forKey: T(stringValue: "type")!)

        guard type == self.type else {
            throw StarknetTransactionDecodingError.invalidType
        }
    }

    func verifyTransactionVersion<T>(container: KeyedDecodingContainer<T>, codingKeysType _: T.Type) throws where T: CodingKey {
        let version = try container.decode(Felt.self, forKey: T(stringValue: "version")!)

        guard version == self.version else {
            throw StarknetTransactionDecodingError.invalidVersion
        }
    }
}
