import BigInt
import Foundation

public struct StarknetInvokeTransactionV3: StarknetInvokeTransaction, StarknetTransactionV3, StarknetExecutableTransaction {
    public let type: StarknetTransactionType = .invoke

    public let version: StarknetTransactionVersion

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let nonce: Felt

    public let resourceBounds: StarknetResourceBoundsMapping

    public let tip: UInt64AsHex

    public let paymasterData: StarknetPaymasterData

    public let accountDeploymentData: StarknetAccountDeploymentData

    public let nonceDataAvailabilityMode: StarknetDAMode

    public let feeDataAvailabilityMode: StarknetDAMode

    public let hash: Felt?

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, l1ResourceBounds: StarknetResourceBounds, nonce: Felt, forFeeEstimation: Bool = false, hash: Felt? = nil) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.nonce = nonce
        self.version = forFeeEstimation ? .v3Query : .v3
        self.hash = hash
        // As of Starknet 0.13, most of v3 fields have hardcoded values.
        self.resourceBounds = StarknetResourceBoundsMapping(l1Gas: l1ResourceBounds)
        self.tip = .zero
        self.paymasterData = []
        self.accountDeploymentData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case senderAddress = "sender_address"
        case calldata
        case signature
        case nonce
        case resourceBounds = "resource_bounds"
        case tip
        case paymasterData = "paymaster_data"
        case accountDeploymentData = "account_deployment_data"
        case nonceDataAvailabilityMode = "nonce_data_availability_mode"
        case feeDataAvailabilityMode = "fee_data_availability_mode"
        case hash = "transaction_hash"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.version = try container.decode(StarknetTransactionVersion.self, forKey: .version)
        self.resourceBounds = try container.decode(StarknetResourceBoundsMapping.self, forKey: .resourceBounds)
        self.tip = try container.decode(UInt64AsHex.self, forKey: .tip)
        self.paymasterData = try container.decode(StarknetPaymasterData.self, forKey: .paymasterData)
        self.accountDeploymentData = try container.decode(StarknetAccountDeploymentData.self, forKey: .accountDeploymentData)
        self.nonceDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .nonceDataAvailabilityMode)
        self.feeDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .feeDataAvailabilityMode)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetInvokeTransactionV1: StarknetInvokeTransaction, StarknetDeprecatedTransaction, StarknetExecutableTransaction {
    public let type: StarknetTransactionType = .invoke

    public let version: StarknetTransactionVersion

    public let senderAddress: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let hash: Felt?

    public init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, forFeeEstimation: Bool = false, hash: Felt? = nil) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.version = forFeeEstimation ? .v1Query : .v1
        self.hash = hash
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
        self.version = try container.decode(StarknetTransactionVersion.self, forKey: .version)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetInvokeTransactionV0: StarknetInvokeTransaction, StarknetDeprecatedTransaction {
    public let type: StarknetTransactionType = .invoke

    public let version: StarknetTransactionVersion = .v0

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: StarknetCalldata

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let hash: Felt?

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case contractAddress = "contract_address"
        case entrypointSelector = "entry_point_selector"
        case calldata
        case signature
        case maxFee = "max_fee"
        case hash = "transaction_hash"
    }

    public init(contractAddress: Felt, entrypointSelector: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, hash: Felt? = nil) {
        self.contractAddress = contractAddress
        self.entrypointSelector = entrypointSelector
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contractAddress = try container.decode(Felt.self, forKey: .contractAddress)
        self.entrypointSelector = try container.decode(Felt.self, forKey: .entrypointSelector)
        self.calldata = try container.decode(StarknetCalldata.self, forKey: .calldata)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
    }
}

public struct StarknetDeployAccountTransactionV3: StarknetDeployAccountTransaction, StarknetTransactionV3, StarknetExecutableTransaction {
    public let type: StarknetTransactionType = .deployAccount

    public let version: StarknetTransactionVersion

    public let signature: StarknetSignature

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public var resourceBounds: StarknetResourceBoundsMapping

    public var tip: UInt64AsHex

    public var paymasterData: StarknetPaymasterData

    public var nonceDataAvailabilityMode: StarknetDAMode

    public var feeDataAvailabilityMode: StarknetDAMode

    public let hash: Felt?

    public init(signature: StarknetSignature, l1ResourceBounds: StarknetResourceBounds, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, forFeeEstimation: Bool = false, hash: Felt? = nil) {
        self.signature = signature
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.version = forFeeEstimation ? .v3Query : .v3
        self.hash = hash
        // As of Starknet 0.13, most of v3 fields have hardcoded values.
        self.resourceBounds = StarknetResourceBoundsMapping(l1Gas: l1ResourceBounds)
        self.tip = .zero
        self.paymasterData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.resourceBounds = try container.decode(StarknetResourceBoundsMapping.self, forKey: .resourceBounds)
        self.tip = try container.decode(UInt64AsHex.self, forKey: .tip)
        self.paymasterData = try container.decode([Felt].self, forKey: .paymasterData)
        self.nonceDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .nonceDataAvailabilityMode)
        self.feeDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .feeDataAvailabilityMode)
        self.version = try container.decode(StarknetTransactionVersion.self, forKey: .version)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionVersion(container: container, codingKeysType: CodingKeys.self)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case signature
        case nonce
        case contractAddressSalt = "contract_address_salt"
        case constructorCalldata = "constructor_calldata"
        case classHash = "class_hash"
        case resourceBounds = "resource_bounds"
        case tip
        case paymasterData = "paymaster_data"
        case nonceDataAvailabilityMode = "nonce_data_availability_mode"
        case feeDataAvailabilityMode = "fee_data_availability_mode"
        case hash = "transaction_hash"
    }
}

public struct StarknetDeployAccountTransactionV1: StarknetDeployAccountTransaction, StarknetDeprecatedTransaction, StarknetExecutableTransaction {
    public let type: StarknetTransactionType = .deployAccount

    public let version: StarknetTransactionVersion

    public let signature: StarknetSignature

    public let maxFee: Felt

    public let nonce: Felt

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public let hash: Felt?

    public init(signature: StarknetSignature, maxFee: Felt, nonce: Felt, contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, forFeeEstimation: Bool = false, hash: Felt? = nil) {
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.contractAddressSalt = contractAddressSalt
        self.constructorCalldata = constructorCalldata
        self.classHash = classHash
        self.version = forFeeEstimation ? .v1Query : .v1
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.contractAddressSalt = try container.decode(Felt.self, forKey: .contractAddressSalt)
        self.constructorCalldata = try container.decode(StarknetCalldata.self, forKey: .constructorCalldata)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.version = try container.decode(StarknetTransactionVersion.self, forKey: .version)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

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
        case hash = "transaction_hash"
    }
}

public struct StarknetL1HandlerTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .l1Handler

    public let version: StarknetTransactionVersion = .v0

    public let nonce: Felt

    public let contractAddress: Felt

    public let entrypointSelector: Felt

    public let calldata: StarknetCalldata

    public let hash: Felt?

    public init(nonce: Felt, contractAddress: Felt, entrypointSelector: Felt, calldata: StarknetCalldata, hash: Felt? = nil) {
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
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

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

public struct StarknetDeclareTransactionV3: StarknetDeclareTransaction, StarknetTransactionV3 {
    public let type: StarknetTransactionType = .declare

    public let version: StarknetTransactionVersion = .v3

    public let signature: StarknetSignature

    public let classHash: Felt

    public let compiledClassHash: Felt

    public let senderAddress: Felt

    public let nonce: Felt

    public let resourceBounds: StarknetResourceBoundsMapping

    public let tip: UInt64AsHex

    public let paymasterData: StarknetPaymasterData

    public let accountDeploymentData: StarknetAccountDeploymentData

    public let nonceDataAvailabilityMode: StarknetDAMode

    public let feeDataAvailabilityMode: StarknetDAMode

    public let hash: Felt?

    public init(signature: StarknetSignature, l1ResourceBounds: StarknetResourceBounds, nonce: Felt, classHash: Felt, compiledClassHash: Felt, senderAddress: Felt, hash: Felt? = nil) {
        self.signature = signature
        self.nonce = nonce
        self.classHash = classHash
        self.compiledClassHash = compiledClassHash
        self.senderAddress = senderAddress
        self.hash = hash
        // As of Starknet 0.13, most of v3 fields have hardcoded values.
        self.resourceBounds = StarknetResourceBoundsMapping(l1Gas: l1ResourceBounds)
        self.tip = .zero
        self.paymasterData = []
        self.accountDeploymentData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.compiledClassHash = try container.decode(Felt.self, forKey: .compiledClassHash)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.resourceBounds = try container.decode(StarknetResourceBoundsMapping.self, forKey: .resourceBounds)
        self.tip = try container.decode(UInt64AsHex.self, forKey: .tip)
        self.paymasterData = try container.decode(StarknetPaymasterData.self, forKey: .paymasterData)
        self.accountDeploymentData = try container.decode(StarknetAccountDeploymentData.self, forKey: .accountDeploymentData)
        self.nonceDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .nonceDataAvailabilityMode)
        self.feeDataAvailabilityMode = try container.decode(StarknetDAMode.self, forKey: .feeDataAvailabilityMode)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: CodingKeys.self)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys.self)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case signature
        case classHash = "class_hash"
        case compiledClassHash = "compiled_class_hash"
        case senderAddress = "sender_address"
        case nonce
        case resourceBounds = "resource_bounds"
        case tip
        case paymasterData = "paymaster_data"
        case accountDeploymentData = "account_deployment_data"
        case nonceDataAvailabilityMode = "nonce_data_availability_mode"
        case feeDataAvailabilityMode = "fee_data_availability_mode"
        case hash = "transaction_hash"
    }
}

public struct StarknetDeclareTransactionV0: StarknetDeclareTransaction, StarknetDeprecatedTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: StarknetTransactionVersion = .v0

    public let signature: StarknetSignature

    public let classHash: Felt

    public let senderAddress: Felt

    public let hash: Felt?

    enum CodingKeys: String, CodingKey {
        case type
        case maxFee = "max_fee"
        case version
        case signature
        case classHash = "class_hash"
        case senderAddress = "sender_address"
        case hash = "transaction_hash"
    }

    public init(maxFee: Felt, signature: StarknetSignature, classHash: Felt, senderAddress: Felt, hash: Felt? = nil) {
        self.maxFee = maxFee
        self.signature = signature
        self.classHash = classHash
        self.senderAddress = senderAddress
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys.self)
    }
}

public struct StarknetDeclareTransactionV1: StarknetDeclareTransaction, StarknetDeprecatedTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: StarknetTransactionVersion = .v1

    public let signature: StarknetSignature

    public let nonce: Felt

    public let classHash: Felt

    public let senderAddress: Felt

    public let hash: Felt?

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

    public init(maxFee: Felt, signature: StarknetSignature, nonce: Felt, classHash: Felt, senderAddress: Felt, hash: Felt? = nil) {
        self.maxFee = maxFee
        self.signature = signature
        self.nonce = nonce
        self.classHash = classHash
        self.senderAddress = senderAddress
        self.hash = hash
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxFee = try container.decode(Felt.self, forKey: .maxFee)
        self.signature = try container.decode(StarknetSignature.self, forKey: .signature)
        self.nonce = try container.decode(Felt.self, forKey: .nonce)
        self.classHash = try container.decode(Felt.self, forKey: .classHash)
        self.senderAddress = try container.decode(Felt.self, forKey: .senderAddress)
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys.self)
    }
}

public struct StarknetDeclareTransactionV2: StarknetTransaction {
    public let type: StarknetTransactionType = .declare

    public let maxFee: Felt

    public let version: StarknetTransactionVersion = .v2

    public let signature: StarknetSignature

    public let nonce: Felt

    public let classHash: Felt

    public let compiledClassHash: Felt

    public let senderAddress: Felt

    public let hash: Felt?

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

    public init(maxFee: Felt, signature: StarknetSignature, nonce: Felt, classHash: Felt, compiledClassHash: Felt, senderAddress: Felt, hash: Felt? = nil) {
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
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys.self)
    }
}

public struct StarknetDeployTransaction: StarknetTransaction {
    public let type: StarknetTransactionType = .deploy

    public let version: StarknetTransactionVersion = .v0

    public let contractAddressSalt: Felt

    public let constructorCalldata: StarknetCalldata

    public let classHash: Felt

    public let hash: Felt?

    enum CodingKeys: String, CodingKey {
        case type
        case version
        case contractAddressSalt = "contract_address_salt"
        case constructorCalldata = "constructor_calldata"
        case classHash = "class_hash"
        case hash = "transaction_hash"
    }

    public init(contractAddressSalt: Felt, constructorCalldata: StarknetCalldata, classHash: Felt, hash: Felt? = nil) {
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
        self.hash = try container.decodeIfPresent(Felt.self, forKey: .hash)

        try verifyTransactionType(container: container, codingKeysType: Self.CodingKeys.self)
        try verifyTransactionVersion(container: container, codingKeysType: Self.CodingKeys.self)
    }
}

public enum StarknetTransactionDecodingError: Error {
    case invalidVersion
    case invalidType
}

extension StarknetExecutableTransaction {
    private static func estimateVersion(_ version: Felt) -> Felt {
        Felt(BigUInt(2).power(128).advanced(by: BigInt(version.value)))!
    }
}

// Default deserializer doesn't check if the fields with default values match what is deserialized.
// It's an extension that resolves this.
extension StarknetTransaction {
    func verifyTransactionType<T>(container: KeyedDecodingContainer<T>, codingKeysType _: T.Type) throws where T: CodingKey {
        let type = try container.decode(StarknetTransactionType.self, forKey: T(stringValue: "type")!)

        guard type == self.type else {
            throw StarknetTransactionDecodingError.invalidType
        }
    }

    func verifyTransactionVersion<T>(container: KeyedDecodingContainer<T>, codingKeysType _: T.Type) throws where T: CodingKey {
        let version = try container.decode(StarknetTransactionVersion.self, forKey: T(stringValue: "version")!)

        guard version == self.version else {
            throw StarknetTransactionDecodingError.invalidVersion
        }
    }
}
