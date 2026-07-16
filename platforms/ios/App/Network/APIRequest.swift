import Foundation

struct APIRequest {
    let method: String
    let path: String
    let body: Data?
    let mockResponseFile: String
    let mockStatusCode: Int
    let mockError: APIError?
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
