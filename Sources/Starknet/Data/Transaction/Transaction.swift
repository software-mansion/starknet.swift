import Foundation

public struct StarknetInvokeTransactionV1: StarknetTransaction {
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
        case hash = "transaction_hash"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetInvokeTransactionV0: StarknetTransaction {
    public let type: StarknetTransactionType = .invoke

    public let version: Felt = .zero

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

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

    public init(contractAddress: Felt, entrypointSelector: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, hash: Felt) {
        self.contractAddress = contractAddress
        self.entrypointSelector = entrypointSelector
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
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
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys)
        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetDeployAccountTransaction: StarknetTransaction {
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

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
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

public struct StarknetL1HandlerTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .l1Handler

    public let version: Felt = .zero

    public let nonce: Felt

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: StarknetCalldata

    public let hash: Felt

    public init(nonce: Felt, contractAddress: Felt, entrypointSelector: Felt, calldata: StarknetCalldata, hash: Felt) {
        self.nonce = nonce
        self.contractAddress = contractAddress
        self.entrypointSelector = entrypointSelector
        self.calldata = calldata
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddress = try container.decode(Felt.self, forKey: .contractAddress)
        self.entrypointSelector = try container.decode(Felt.self, forKey: .entrypointSelector)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
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

public struct StarknetDeclareTransactionV1: StarknetTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: Felt // Not setting version here, as both v0 and v1 have this same structure

    public let signature: StarknetSignature

    public let nonce: Felt

    public let classHash: Felt

    public let senderAddress: Felt

    public let hash: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case maxFee = "max_fee"
        case version
        case signature
        case nonce
        case classHash = "class_hash"
        case senderAddress = "sender_address"
        case hash = "transaction_hash"
    }

    public init(maxFee: Felt, version: Felt, signature: StarknetSignature, nonce: Felt, classHash: Felt, senderAddress: Felt, hash: Felt) {
        self.maxFee = maxFee
        self.version = version
        self.signature = signature
        self.nonce = nonce
        self.classHash = classHash
        self.senderAddress = senderAddress
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.version = try container.decode(Felt.self, forKey: .version)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys)
    }
}

public struct StarknetDeclareTransactionV2: StarknetTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: Felt = 2

    public let signature: StarknetSignature

    public let nonce: Felt

    public let classHash: Felt

    public let compiledClassHash: Felt

    public let senderAddress: Felt

    public let hash: Felt

    enum CodingKeys: String, CodingKey {
        case type
        case maxFee = "max_fee"
        case version
        case signature
        case nonce
        case classHash = "class_hash"
        case compiledClassHash = "compiled_class_hash"
        case senderAddress = "sender_address"
        case hash = "transaction_hash"
    }

    public init(maxFee: Felt, signature: StarknetSignature, nonce: Felt, classHash: Felt, compiledClassHash: Felt, senderAddress: Felt, hash: Felt) {
        self.maxFee = maxFee
        self.signature = signature
        self.nonce = nonce
        self.classHash = classHash
        self.compiledClassHash = compiledClassHash
        self.senderAddress = senderAddress
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.compiledClassHash = try container.decode(Felt.self, forKey: .compiledClassHash)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys)
    }
}

public struct StarknetDeployTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .deploy

    public let version: Felt = .zero

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

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

    public init(contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, hash: Felt) {
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.hash = try container.decode(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys)
    }
}

public enum StarknetTransactionDecodingError: Error {
    case invalidVersion
    case invalidType
}

// Default deserializer doesn't check if the fields with default values match what is deserialized.
// It's an extension that resolves this.
internal extension StarknetSequencerTransaction {
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
