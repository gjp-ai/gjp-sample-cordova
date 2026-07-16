import Foundation

struct AppSettings: Decodable {
    let isMockMode: Bool
    let apiBaseUrl: String
    let requestTimeoutSeconds: TimeInterval
    let mockResponseDelayMilliseconds: Int

    static func load(bundle: Bundle = .main) throws -> AppSettings {
        guard let url = bundle.url(forResource: "AppSettings", withExtension: "json") else {
            throw APIError.configuration
        }
        let settings = try JSONDecoder().decode(AppSettings.self, from: Data(contentsOf: url))
        guard !settings.apiBaseUrl.isEmpty else {
            throw APIError.configuration
        }
        return settings
    }
}
