import Foundation

enum LoginMockScenario: String, CaseIterable {
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

    var title: String {
        switch self {
        case .success: return "Success"
        case .invalidCredentials: return "Invalid credentials"
        case .validationError: return "Validation error"
        case .accountLocked: return "Account locked"
        case .rateLimited: return "Rate limited"
        case .serverError: return "Server error"
        case .malformedResponse: return "Malformed response"
        case .emptyResponse: return "Empty response"
        case .missingPayload: return "Missing payload"
        case .networkError: return "Network error"
        case .timeout: return "Request timeout"
        }
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

    var isMockMode: Bool {
        apiClient.isMockMode
    }

    func setMockMode(_ enabled: Bool) {
        apiClient.setMockMode(enabled)
    }

    func login(
        username: String,
        password: String,
        mockScenario: LoginMockScenario,
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
        do {
            let body = try JSONSerialization.data(withJSONObject: [
                "username": username,
                "password": password
            ])
            apiClient.execute(APIRequest(
                method: "POST",
                path: "login",
                body: body,
                mockResponseFile: mockScenario.responseFile,
                mockStatusCode: mockScenario.statusCode,
                mockError: mockScenario.apiError
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

struct LoginResponse: Decodable {
    struct ResponseData: Decodable {
        struct User: Decodable {
            let id: String?
            let displayName: String?
        }

        let accessToken: String?
        let user: User?
    }

    let success: Bool
    let message: String?
    let data: ResponseData?

    func result() -> Result<LoginSession, LoginError> {
        guard success else {
            return .failure(.service(message ?? "Unable to sign in. Please try again."))
        }

        guard let data, let accessToken = data.accessToken, !accessToken.isEmpty, data.user != nil else {
            return .failure(.invalidResponse)
        }

        return .success(LoginSession(
            accessToken: accessToken,
            userId: data.user?.id ?? "",
            displayName: data.user?.displayName ?? ""
        ))
    }
}

enum LoginResponseParser {
    static func parse(_ data: Data) -> Result<LoginSession, LoginError> {
        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data).result()
        } catch {
            return .failure(.invalidResponse)
        }
    }
}
