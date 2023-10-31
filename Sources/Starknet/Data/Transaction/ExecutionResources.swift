import Foundation

public struct StarknetExecutionResources: Decodable, Equatable {
    public let steps: NumAsHex
    public let memoryHoles: NumAsHex?
    public let rangeCheckApplications: NumAsHex
    public let pedersenApplications: NumAsHex
    public let poseidonApplications: NumAsHex
    public let ecOpApplications: NumAsHex
    public let ecdsaApplications: NumAsHex
    public let bitwiseApplications: NumAsHex
    public let keccakApplications: NumAsHex

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
