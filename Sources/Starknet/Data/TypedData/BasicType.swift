import Foundation

extension StarknetTypedData {
    enum BasicType: String, CaseIterable {
        case felt
        case bool
        case selector
        case string
        case u128
        case i128
        case `enum`
        case merkletree
        case contractAddress = "ContractAddress"
        case classHash = "ClassHash"
        case timestamp
        case shortstring

        static func cases(revision: Revision) -> [BasicType] {
            switch revision {
            case .v0: [.felt, .bool, .selector, .string, .merkletree]
            case .v1: allCases
            }
        }
    }
}
