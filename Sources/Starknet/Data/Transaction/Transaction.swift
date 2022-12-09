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
}
