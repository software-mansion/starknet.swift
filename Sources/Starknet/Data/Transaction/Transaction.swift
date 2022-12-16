import Foundation

public struct StarknetSequencerInvokeTransaction: StarknetSequencerTransaction, Codable {
    public let type: StarknetTransactionType = .invoke
    
    public let version: Felt = Felt.one
    
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
    
    init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt) {
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

public struct StarknetInvokeTransaction: StarknetTransaction, Codable {
    public let type: StarknetTransactionType = .invoke
    
    public let version: Felt = Felt.one
    
    public let senderAddress: Felt
    
    public let calldata: StarknetCalldata
    
    public let signature: StarknetSignature
    
    public let maxFee: Felt
    
    public let nonce: Felt
    
    public let hash: Felt
    
    init(senderAddress: Felt, calldata: StarknetCalldata, signature: StarknetSignature, maxFee: Felt, nonce: Felt, hash: Felt) {
        self.senderAddress = senderAddress
        self.calldata = calldata
        self.signature = signature
        self.maxFee = maxFee
        self.nonce = nonce
        self.hash = hash
    }
    
    init(sequencerTransaction: StarknetSequencerInvokeTransaction, hash: Felt) {
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


public enum StarknetTransactionDecodingError: Error {
    case invalidVersion
    case invalidType
}

// Default deserializer doesn't check if the fields with default values match what is deserialized.
// It's an extension that resolves this.
internal extension StarknetSequencerTransaction {
    func verifyTransactionIdentifiers<T>(container: KeyedDecodingContainer<T>, codingKeysType: T.Type) throws where T: CodingKey {
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

