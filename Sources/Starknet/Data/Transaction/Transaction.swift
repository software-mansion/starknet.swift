import Foundation

public struct StarknetSequencerInvokeTransaction: StarknetSequencerTransaction, Equatable {
    public let type: StarknetTransactionType = .invoke

    public let version: Felt = .one

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case senderAddress = "sender_address"
        case calldata
        case signature
        case maxFee = "max_fee"
        case nonce
    }

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)

        try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetInvokeTransaction: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .invoke

    public let version: Felt = .one

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let hash: Felt

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, hash: Felt) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.hash = hash
    }

    public init(sequencerTransaction: StarknetSequencerInvokeTransaction, hash: Felt) {
        self.init(
            senderAddress: sequencerTransaction.senderAddress,
            calldata: sequencerTransaction.calldata,
            signature: sequencerTransaction.signature,
            maxFee: sequencerTransaction.maxFee,
            nonce: sequencerTransaction.nonce,
            hash: hash
        )
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case senderAddress = "sender_address"
        case calldata
        case signature
        case maxFee = "max_fee"
        case nonce
        case hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetSequencerDeployAccountTransaction: StarknetSequencerTransaction, Equatable {
    public let type: StarknetTransactionType = .deployAccount

    public let version: Felt = .one

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public init(signature: StarknetSignature, maxFee: Felt, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt) {
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
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

public struct StarknetDeployAccountTransaction: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .deployAccount

    public let version: Felt = .one

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public let hash: Felt

    public init(signature: StarknetSignature, maxFee: Felt, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, hash: Felt) {
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.hash = hash
    }

    public init(sequencerTransaction: StarknetSequencerDeployAccountTransaction, hash: Felt) {
        self.init(
            signature: sequencerTransaction.signature,
            maxFee: sequencerTransaction.maxFee,
            nonce: sequencerTransaction.nonce,
            contractAddressSalt: sequencerTransaction.contractAddressSalt,
            constructorCalldata: sequencerTransaction.constructorCalldata,
            classHash: sequencerTransaction.classHash,
            hash: hash
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
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
        case hash
    }
}

public enum StarknetTransactionDecodingError: Error {
    case invalidVersion
    case invalidType
}

// Default deserializer doesn't check if the fields with default values match what is deserialized.
// It's an extension that resolves this.
internal extension StarknetSequencerTransaction {
    func verifyTransactionIdentifiers<T>(container: KeyedDecodingContainer<T>, codingKeysType _: T.Type) throws where T: CodingKey {
        let type = try container.decode(StarknetTransactionType.self, forKey: T(stringValue: "type")!)
        let version = try container.decode(Felt.self, forKey: T(stringValue: "version")!)

        guard type == self.type else {
            throw StarknetTransactionDecodingError.invalidType
        }

        guard version == self.version else {
            throw StarknetTransactionDecodingError.invalidVersion
        }
    }
}
