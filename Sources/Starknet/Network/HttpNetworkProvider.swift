import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

enum HttpNetworkProviderError: Error {
    case encodingError(EncodingError)
    case decodingError(DecodingError)
    case unknownError
    case requestRejected
}

class HttpNetworkProvider {
    let session: URLSession

    struct Configuration {
        let url: URL
        let method: String
        let params: [(header: String, value: String)]

        init(url: URL, method: String, params: [(header: String, value: String)] = []) {
            self.url = url
            self.method = method
            self.params = params
        }
    }

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    deinit {
        session.invalidateAndCancel()
    }

    private func makeRequestWith(body: Data, config: Configuration) -> URLRequest {
        var request = URLRequest(url: config.url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = config.method

        for (header, value) in config.params {
            request.addValue(value, forHTTPHeaderField: header)
        }

        request.httpBody = body

        return request
    }

    private func handleEncodingError(_ error: Error) throws -> Never {
        if let encodingError = error as? EncodingError {
            throw HttpNetworkProviderError.encodingError(encodingError)
        } else {
            throw HttpNetworkProviderError.unknownError
        }
    }

    private func handleResponseError(_ error: Error, _ response: URLResponse) throws -> Never {
        if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode > 299 {
            throw HttpNetworkProviderError.requestRejected
        } else if let decodingError = error as? DecodingError {
            throw HttpNetworkProviderError.decodingError(decodingError)
        } else {
            throw HttpNetworkProviderError.unknownError
        }
    }

    func send<U>(payload: some Encodable, config: Configuration, receive _: U.Type) async throws -> U where U: Decodable {
        let encoded: Data
        do {
            encoded = try JSONEncoder().encode(payload)
        } catch {
            try handleEncodingError(error)
        }

        let request = makeRequestWith(body: encoded, config: config)

        guard let (data, response) = try? await session.data(for: request) else {
            throw HttpNetworkProviderError.unknownError
        }

        do {
            let result = try JSONDecoder().decode(U.self, from: data)
            return result
        } catch {
            try handleResponseError(error, response)
        }
    }

    func send<U>(payload: [some Encodable], config: Configuration, receive _: [U.Type]) async throws -> [U] where U: Decodable {
        let encoded: Data
        do {
            encoded = try JSONEncoder().encode(payload)
        } catch {
            try handleEncodingError(error)
        }

        let request = makeRequestWith(body: encoded, config: config)

        guard let (data, response) = try? await session.data(for: request) else {
            throw HttpNetworkProviderError.unknownError
        }

        do {
            let result = try JSONDecoder().decode([U].self, from: data)
            return result
        } catch {
            try handleResponseError(error, response)
        }
    }
}
