import Foundation

public struct ExecutionResources: Decodable, Equatable {
    public let steps: Felt
    public let memoryHoles: Felt?
    public let rangeCheckApplications: Felt
    public let pedersenApplications: Felt
    public let poseidonApplications: Felt
    public let ecOpApplications: Felt
    public let ecdsaApplications: Felt
    public let bitwiseApplications: Felt
    public let keccakApplications: Felt

    enum CodingKeys: String, CodingKey {
        case steps
        case memoryHoles = "memory_holes"
        case rangeCheckApplications = "range_check_builtin_applications"
        case pedersenApplications = "pedersen_builtin_applications"
        case poseidonApplications = "poseidon_builtin_applications"
        case ecOpApplications = "ec_op_builtin_applications"
        case ecdsaApplications = "ecdsa_builtin_applications"
        case bitwiseApplications = "bitwise_builtin_applications"
        case keccakApplications = "keccak_builtin_applications"
    }
}
