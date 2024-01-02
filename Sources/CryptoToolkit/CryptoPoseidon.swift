import CFrameworkWrapper
import Foundation

public enum CryptoPoseidon {
    public static func hades(
        _ values: [(UInt64, UInt64, UInt64, UInt64)]
    ) -> [(UInt64, UInt64, UInt64, UInt64)] {
        var state = values
        permutation_3(&state)
        return state
    }
}
