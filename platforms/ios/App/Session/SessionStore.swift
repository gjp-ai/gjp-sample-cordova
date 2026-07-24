import Foundation

final class SessionStore {
    static let shared = SessionStore()

    private let lock = NSLock()
    private var session: LoginSession?

    private init() {}

    var authorizationHeader: String? {
        lock.lock()
        defer { lock.unlock() }
        guard let session, session.expiresAt > Date() else {
            self.session = nil
            return nil
        }
        return "\(session.tokenType) \(session.accessToken)"
    }

    var isAuthenticated: Bool {
        authorizationHeader != nil
    }

    func save(_ session: LoginSession) {
        lock.lock()
        self.session = session
        lock.unlock()
    }

    func clear() {
        lock.lock()
        session = nil
        lock.unlock()
    }
}
