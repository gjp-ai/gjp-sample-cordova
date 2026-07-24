import Foundation

struct APIRequestMetadata: Encodable {
    let requestId = UUID().uuidString.lowercased()
    let sentAt: String
    let apiVersion = "1.0"
    let channel = "MOBILE"
    let locale = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")

    init(now: Date = Date()) {
        sentAt = ISO8601DateFormatter.api.string(from: now)
    }
}

private extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

enum APIOutcome: String, Decodable {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case partial = "PARTIAL"
}

struct APIResponseMetadata: Decodable {
    let requestId: String
    let responseId: String
    let respondedAt: String
    let outcome: APIOutcome
}

struct APIErrorPayload: Decodable {
    let code: String
    let message: String
    let field: String?
    let retryable: Bool
    let retryAfterSeconds: Int?
}

struct APIEnvelope<Payload: Decodable>: Decodable {
    let meta: APIResponseMetadata
    let data: Payload?
    let errors: [APIErrorPayload]
}

struct APIRequest {
    let method: String
    let path: String
    let body: Data?
    let mockResponseFile: String
    let mockStatusCode: Int
    let mockError: APIError?
    let mockModeOverride: Bool?
    let requiresAuthentication: Bool
}

struct APIResponse {
    let statusCode: Int
    let data: Data
}

enum APIError: LocalizedError {
    case configuration
    case invalidResponse
    case mockResponseNotFound
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .configuration:
            return "The application settings are invalid."
        case .invalidResponse:
            return "The API returned an invalid response."
        case .mockResponseNotFound:
            return "The local mock response could not be loaded."
        case .transport(let message):
            return message
        }
    }
}
