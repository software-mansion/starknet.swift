import Foundation

public extension StarknetTypedData {
    protocol PresetTypeDeclaration: Codable, Hashable, Equatable {
        var params: [TypeDeclarationWrapper] { get }
    }

    enum PresetType: String, PresetTypeDeclaration, Encodable, Hashable, Equatable, CaseIterable {
        case u256
        case tokenAmount = "TokenAmount"
        case nftId = "NftId"

        public var params: [TypeDeclarationWrapper] {
            switch self {
            case .u256:
                [TypeDeclarationWrapper.standard(.init(name: "low", type: BasicType.u128.rawValue)), TypeDeclarationWrapper.standard(.init(name: "high", type: BasicType.u128.rawValue))]
            case .tokenAmount:
                [TypeDeclarationWrapper.standard(.init(name: "token_address", type: BasicType.contractAddress.rawValue)), TypeDeclarationWrapper.standard(.init(name: "amount", type: Self.u256.rawValue))]
            case .nftId:
                [TypeDeclarationWrapper.standard(.init(name: "collection_address", type: BasicType.contractAddress.rawValue)), TypeDeclarationWrapper.standard(.init(name: "token_id", type: Self.u256.rawValue))]
            }
        }

        fileprivate enum CodingKeys: CodingKey {
            case u256
            case tokenAmount
            case nftId
        }

        static func values(revision: Revision) -> [PresetType] {
            switch revision {
            case .v0: []
            case .v1: [.u256, .tokenAmount, .nftId]
            }
        }
    }
}
