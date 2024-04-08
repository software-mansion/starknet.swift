import Foundation

public extension String {
    func splitToShortStrings() -> [String] {
        self.components(withMaxLength: 31)
    }
}

extension String {
    func components(withMaxLength length: Int) -> [String] {
        stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start ..< end])
        }
    }
}
