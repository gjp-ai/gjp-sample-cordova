import Foundation

private struct LoginRequest: Encodable {
    struct Credentials: Encodable {
        let username: String
        let password: String
    }

    let meta = APIRequestMetadata()
    let data: Credentials
}

enum LoginMockScenario: String {
    case success
    case invalidCredentials
    case validationError
    case accountLocked
    case rateLimited
    case serverError
    case malformedResponse
    case emptyResponse
    case missingPayload
    case networkError
    case timeout

    static let mockUsername = "mock"

    static func from(password: String) -> LoginMockScenario? {
        let normalized = password
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
        let scenarioName = normalized
            .split(separator: "-")
            .enumerated()
            .map { index, component in
                index == 0 ? String(component) : component.capitalized
            }
            .joined()
        return LoginMockScenario(rawValue: scenarioName)
    }

    var responseFile: String {
        switch self {
        case .success: return "LoginSuccess.json"
        case .invalidCredentials: return "LoginInvalidCredentials.json"
        case .validationError: return "LoginValidationError.json"
        case .accountLocked: return "LoginAccountLocked.json"
        case .rateLimited: return "LoginRateLimited.json"
        case .serverError: return "LoginServerError.json"
        case .malformedResponse: return "LoginMalformed.json"
        case .emptyResponse: return "LoginEmpty.json"
        case .missingPayload: return "LoginMissing.json"
        case .networkError, .timeout: return ""
        }
    }

    var statusCode: Int {
        switch self {
        case .success, .malformedResponse, .emptyResponse, .missingPayload: return 200
        case .validationError: return 400
        case .invalidCredentials: return 401
        case .accountLocked: return 423
        case .rateLimited: return 429
        case .serverError: return 500
        case .networkError, .timeout: return 0
        }
    }

    var apiError: APIError? {
        switch self {
        case .networkError:
            return .transport("Unable to connect to the login service.")
        case .timeout:
            return .transport("The login request timed out. Please try again.")
        default:
            return nil
        }
    }
}

final class LoginService {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func login(
        username: String,
        password: String,
        completion: @escaping (Result<LoginSession, LoginError>) -> Void
    ) {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.validation("Enter your username.")))
            return
        }
        guard !password.isEmpty else {
            completion(.failure(.validation("Enter your password.")))
            return
        }
        let isMockLogin = username.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(LoginMockScenario.mockUsername) == .orderedSame
        let mockScenario = isMockLogin
            ? LoginMockScenario.from(password: password)
            : .success
        guard let mockScenario else {
            completion(.failure(.validation(
                "Unknown mock scenario. Use success or another documented scenario."
            )))
            return
        }
        do {
            let body = try JSONEncoder().encode(LoginRequest(
                data: .init(username: username, password: password)
            ))
            apiClient.execute(APIRequest(
                method: "POST",
                path: "login",
                body: body,
                mockResponseFile: mockScenario.responseFile,
                mockStatusCode: mockScenario.statusCode,
                mockError: mockScenario.apiError,
                mockModeOverride: isMockLogin,
                requiresAuthentication: false
            )) { result in
                switch result {
                case .success(let response):
                    let parsed = LoginResponseParser.parse(response.data)
                    if !(200..<300).contains(response.statusCode), case .success = parsed {
                        completion(.failure(.service("Login failed with status \(response.statusCode).")))
                    } else {
                        completion(parsed)
                    }
                case .failure(let error):
                    completion(.failure(.api(error)))
                }
            }
        } catch {
            completion(.failure(.invalidResponse))
        }
    }

    func cancel() {
        apiClient.cancel()
    }
}

struct LoginSession {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresAt: Date
    let userId: String
    let displayName: String
}

enum LoginError: LocalizedError {
    case api(APIError)
    case invalidResponse
    case service(String)
    case validation(String)

    var errorDescription: String? {
        switch self {
        case .api(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "The login service returned an invalid response."
        case .service(let message):
            return message
        case .validation(let message):
            return message
        }
    }
}

private struct LoginResponseData: Decodable {
    struct Session: Decodable {
        let accessToken: String
        let refreshToken: String
        let tokenType: String
        let expiresInSeconds: Int
    }

    struct Customer: Decodable {
        let customerId: String
        let displayName: String?
        let lastLoginAt: String?
    }

    let session: Session
    let customer: Customer
}

enum LoginResponseParser {
    static func parse(_ data: Data) -> Result<LoginSession, LoginError> {
        do {
            let envelope = try JSONDecoder().decode(
                APIEnvelope<LoginResponseData>.self,
                from: data
            )
            guard envelope.meta.outcome == .success else {
                guard !envelope.errors.isEmpty else {
                    return .failure(.invalidResponse)
                }
                return .failure(.service(
                    envelope.errors[0].message
                ))
            }
            guard let payload = envelope.data,
                  envelope.errors.isEmpty,
                  !payload.session.accessToken.isEmpty,
                  !payload.session.refreshToken.isEmpty,
                  payload.session.tokenType == "Bearer",
                  payload.session.expiresInSeconds > 0,
                  !payload.customer.customerId.isEmpty else {
                return .failure(.invalidResponse)
            }
            return .success(LoginSession(
                accessToken: payload.session.accessToken,
                refreshToken: payload.session.refreshToken,
                tokenType: payload.session.tokenType,
                expiresAt: Date().addingTimeInterval(
                    TimeInterval(payload.session.expiresInSeconds)
                ),
                userId: payload.customer.customerId,
                displayName: payload.customer.displayName ?? ""
            ))
        } catch {
            return .failure(.invalidResponse)
        }
    }
}
