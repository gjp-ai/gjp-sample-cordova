import Foundation

final class APIClient {
    private let bundle: Bundle
    private let session: URLSession
    private let settings: AppSettings?
    private var mockMode: Bool
    private var tasks: [UUID: URLSessionDataTask] = [:]
    private var activeRequestIds = Set<UUID>()

    init(bundle: Bundle = .main, session: URLSession = .shared) {
        self.bundle = bundle
        self.session = session
        settings = try? AppSettings.load(bundle: bundle)
        mockMode = settings?.isMockMode ?? false
    }

    var isMockMode: Bool {
        mockMode
    }

    func setMockMode(_ enabled: Bool) {
        mockMode = enabled
    }

    func execute(
        _ apiRequest: APIRequest,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        guard let settings else {
            completion(.failure(.configuration))
            return
        }

        let requestId = UUID()
        activeRequestIds.insert(requestId)
        if mockMode {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + .milliseconds(max(settings.mockResponseDelayMilliseconds, 0))
            ) { [weak self] in
                guard let self, self.activeRequestIds.remove(requestId) != nil else { return }
                if let error = apiRequest.mockError {
                    completion(.failure(error))
                } else {
                    completion(self.loadMockResponse(
                        named: apiRequest.mockResponseFile,
                        statusCode: apiRequest.mockStatusCode
                    ))
                }
            }
            return
        }

        guard let request = makeURLRequest(apiRequest, settings: settings) else {
            activeRequestIds.remove(requestId)
            completion(.failure(.configuration))
            return
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            let result: Result<APIResponse, APIError>
            if error != nil {
                result = .failure(.transport("Unable to reach the API. Please try again."))
            } else if let data, let response = response as? HTTPURLResponse {
                result = .success(APIResponse(statusCode: response.statusCode, data: data))
            } else {
                result = .failure(.invalidResponse)
            }

            DispatchQueue.main.async {
                guard let self, self.activeRequestIds.remove(requestId) != nil else { return }
                self.tasks.removeValue(forKey: requestId)
                completion(result)
            }
        }
        tasks[requestId] = task
        task.resume()
    }

    func cancel() {
        activeRequestIds.removeAll()
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }

    private func makeURLRequest(_ request: APIRequest, settings: AppSettings) -> URLRequest? {
        let baseUrlString = settings.apiBaseUrl.hasSuffix("/")
            ? settings.apiBaseUrl
            : settings.apiBaseUrl + "/"
        guard let baseUrl = URL(string: baseUrlString),
              let url = URL(string: request.path, relativeTo: baseUrl)?.absoluteURL else {
            return nil
        }

        var urlRequest = URLRequest(
            url: url,
            timeoutInterval: max(settings.requestTimeoutSeconds, 1)
        )
        urlRequest.httpMethod = request.method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = request.body {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }
        return urlRequest
    }

    private func loadMockResponse(
        named fileName: String,
        statusCode: Int
    ) -> Result<APIResponse, APIError> {
        let name = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            return .failure(.mockResponseNotFound)
        }
        do {
            return .success(APIResponse(statusCode: statusCode, data: try Data(contentsOf: url)))
        } catch {
            return .failure(.mockResponseNotFound)
        }
    }
}
