import Foundation

public struct StarknetCurveSignature {
    public let r: Felt
    public let s: Felt
    
    public func toArray() -> [Felt] {
        return [r, s]
    }
}
