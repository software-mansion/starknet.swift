import Foundation

public struct StarknetStateDiff: Decodable, Equatable {
    public let storageDiffs: [StarknetContractStorageDiffItem]
    public let deprecatedDeclaredClasses: [Felt]
    public let declaredClasses: [StarknetDeclaredClassItem]
    public let deployedContracts: [StarknetDeployedContractItem]
    public let replacedClasses: [StarknetReplacedClassItem]
    public let nonces: [StarknetNonceUpdateItem]

    enum CodingKeys: String, CodingKey {
        case storageDiffs = "storage_diffs"
        case deprecatedDeclaredClasses = "deprecated_declared_classes"
        case declaredClasses = "declared_classes"
        case deployedContracts = "deployed_contracts"
        case replacedClasses = "replaced_classes"
        case nonces
    }
}
