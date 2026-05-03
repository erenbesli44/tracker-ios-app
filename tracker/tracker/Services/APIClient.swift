import Foundation

nonisolated enum APIError: Error, LocalizedError, Equatable {
    case badResponse(statusCode: Int)
    case notFound
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .badResponse(let code):
            return "Unable to load data (status \(code))."
        case .notFound:
            return "Content not found."
        case .unauthorized:
            return "Unauthorized — check API key."
        }
    }
}

// Allows HTTP / self-signed certs (dev only)
private final class InsecureSessionDelegate: NSObject, URLSessionDelegate, Sendable {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }
        return (.useCredential, URLCredential(trust: trust))
    }
}

actor APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "http://t122yraee5v724x7tonr3d6g.204.168.192.245.sslip.io")!
    private let apiKeyHeader = "X-API-Key"

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        // Bypass ATS for development
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        return URLSession(configuration: config, delegate: InsecureSessionDelegate(), delegateQueue: nil)
    }()

    private func authorized(_ url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(Secrets.trackerAPIKey, forHTTPHeaderField: apiKeyHeader)
        return request
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(http.statusCode) else {
            switch http.statusCode {
            case 401: throw APIError.unauthorized
            case 404: throw APIError.notFound
            default: throw APIError.badResponse(statusCode: http.statusCode)
            }
        }
    }

    func fetch<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let request = authorized(url)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try decoder.decode(T.self, from: data)
    }

    func postEmpty<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let request = authorized(url, method: "POST")

        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try decoder.decode(T.self, from: data)
    }

    func post<T: Decodable & Sendable>(
        _ type: T.Type,
        path: String,
        body: some Encodable & Sendable
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = authorized(url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try decoder.decode(T.self, from: data)
    }
}
