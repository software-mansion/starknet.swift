import Foundation


public struct StarknetInvokeTransaction: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .invoke

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let version: Felt

    public let hash: Felt

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, version: Felt, hash: Felt) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.version = version
        self.hash = hash
    }

    public init(sequencerTransaction: StarknetSequencerInvokeTransaction, hash: Felt) {
        self.init(
            senderAddress: sequencerTransaction.senderAddress,
            calldata: sequencerTransaction.calldata,
            signature: sequencerTransaction.signature,
            maxFee: sequencerTransaction.maxFee,
            nonce: sequencerTransaction.nonce,
            version: sequencerTransaction.version,
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
        case hash = "transaction_hash"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetInvokeTransactionV0: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .invoke

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let version: Felt

    public let hash: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case contractAddress = "contract_address"
        case entrypointSelector = "entry_point_selector"
        case calldata
        case signature
        case maxFee = "max_fee"
        case nonce
        case hash = "transaction_hash"
    }

    public init(contractAddress: Felt, entrypointSelector: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, version: Felt, hash: Felt) {
        self.contractAddress = contractAddress
        self.entrypointSelector = entrypointSelector
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.version = version
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contractAddress = try container.decode(Felt.self, forKey: .contractAddress)
        self.entrypointSelector = try container.decode(Felt.self, forKey: .entrypointSelector)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: Self.CodingKeys)
    }
}

public struct StarknetDeployAccountTransaction: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .deployAccount

    public let version: Felt

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public let hash: Felt

    public init(signature: StarknetSignature, maxFee: Felt, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, version: Felt, hash: Felt) {
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.version = version
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
            version: sequencerTransaction.version,
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
        self.version = try container.decode(Felt.self, forKey: .version)
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
        case hash = "transaction_hash"
    }
}

public struct StarknetL1HandlerTransaction: StarknetTransaction, Equatable {
    public let type: StarknetTransactionType = .l1Handler

    public let version: Felt

    public let nonce: Felt

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: [Felt]

    public let hash: Felt

    public init(version: Felt, nonce: Felt, contractAddress: Felt, entrypointSelector: Felt, calldata: [Felt], hash: Felt) {
        self.version = version
        self.nonce = nonce
        self.contractAddress = contractAddress
        self.entrypointSelector = entrypointSelector
        self.calldata = calldata
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddress = try container.decode(Felt.self, forKey: .contractAddress)
        self.entrypointSelector = try container.decode(Felt.self, forKey: .entrypointSelector)
        self.calldata = try container.decode([Felt].self, forKey: .calldata)
        self.hash = try container.decode(Felt.self, forKey: .hash)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case nonce
        case hash = "transaction_hash"
        case contractAddress = "contract_address"
        case entrypointSelector = "entry_point_selector"
        case calldata
    }
}

public struct StarknetDeclareTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: Felt

    public let signature: [Felt]

    public let nonce: Felt

    public let classHash: Felt

    public let address: Felt

    public let hash: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case maxFee = "max_fee"
        case version
        case signature
        case nonce
        case classHash = "class_hash"
        case address = "sender_address"
        case hash = "transaction_hash"
    }

    public init(maxFee: Felt, version: Felt, signature: [Felt], nonce: Felt, classHash: Felt, address: Felt, hash: Felt) {
        self.maxFee = maxFee
        self.version = version
        self.signature = signature
        self.nonce = nonce
        self.classHash = classHash
        self.address = address
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.signature = try container.decode([Felt].self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.address = try container.decode(Felt.self, forKey: .address)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionIdentifiers(container: container, codingKeysType: Self.CodingKeys)
    }
}

public struct StarknetDeployTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .deploy

    public let version: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: [Felt]

    public let classHash: Felt

    public let hash: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case contractAddressSalt = "contract_address_salt"
        case constructorCalldata = "constructor_calldata"
        case classHash = "class_hash"
        case hash = "transaction_hash"
    }

    public init(version: Felt, contractAddressSalt: Felt, constructorCalldata: [Felt], classHash: Felt, hash: Felt) {
        self.version = version
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode([Felt].self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.hash = try container.decode(Felt.self, forKey: .hash)
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

        guard type == self.type else {
            throw StarknetTransactionDecodingError.invalidType
        }
    }
}
