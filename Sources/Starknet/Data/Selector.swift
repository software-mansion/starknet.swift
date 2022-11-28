import Foundation


/// Get a felt value of a contract's entry point selector provided as a string.
/// 
/// - Parameters:
///     - name: a name of the entrypoint
/// - Returns: Felt value of the entrypoint selector
public func starknetSelector(from name: String) -> Felt {
    if name == "__default__" || name == "__l1_default__" {
        return Felt.zero
    }
    
    return keccak(on: name.bytes)
}
