import Foundation

final class MockURLProtocol: URLProtocol {
    static var mockResponse: (statusCode: Int, body: Data)?

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let mock = MockURLProtocol.mockResponse else {
            fatalError("Mock response not set")
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: mock.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: mock.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

func makeMockedURLSession(
    statusCode: Int = 200,
    data: Data
) -> URLSession {
    MockURLProtocol.mockResponse = (
        statusCode: statusCode,
        body: data
    )

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]

    return URLSession(configuration: config)
}
