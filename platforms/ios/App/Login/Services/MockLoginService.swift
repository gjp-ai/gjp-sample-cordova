import Foundation

protocol LoginServicing {
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<Void, LoginError>) -> Void
    )
}

enum LoginError: LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Use the demo credentials shown below."
        }
    }
}

struct MockLoginService: LoginServicing {
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<Void, LoginError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            guard username == "demo", password == "demo" else {
                completion(.failure(.invalidCredentials))
                return
            }
            completion(.success(()))
        }
    }
}
