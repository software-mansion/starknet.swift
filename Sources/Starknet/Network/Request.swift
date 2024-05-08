protocol Request {
    associatedtype Result: Decodable
    func send() async throws -> Result
}
