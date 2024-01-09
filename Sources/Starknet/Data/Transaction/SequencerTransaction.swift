import BigInt
import Foundation

// Sending requests with invoke v0 transaction is not supported starting starknet 0.11
private let invokeVersion: Felt = .one

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
