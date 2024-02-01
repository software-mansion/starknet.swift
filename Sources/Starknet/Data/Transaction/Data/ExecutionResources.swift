import Foundation

public struct StarknetExecutionResources: Decodable, Equatable {
    public let steps: Int
    public let memoryHoles: Int?
    public let rangeCheckApplications: Int?
    public let pedersenApplications: Int?
    public let poseidonApplications: Int?
    public let ecOpApplications: Int?
    public let ecdsaApplications: Int?
    public let bitwiseApplications: Int?
    public let keccakApplications: Int?

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
