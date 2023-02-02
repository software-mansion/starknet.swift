import Foundation

public struct StarknetCurveSignature: Codable {
    public let r: Felt
    public let s: Felt

    public func toArray() -> [Felt] {
        [r, s]
    }
}
