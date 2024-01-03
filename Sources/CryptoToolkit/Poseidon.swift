import CFrameworkWrapper
import Foundation

public class CryptoPoseidon {
    public class func hades(
        _ values: [(UInt64, UInt64, UInt64, UInt64)]
    ) -> [(UInt64, UInt64, UInt64, UInt64)] {
        var state = values
        permutation_3(&state)
        return state
    }
}
