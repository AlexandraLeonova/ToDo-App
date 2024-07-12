import Foundation

public extension URLSession {

    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            dataTask(with: urlRequest) { data, response, error in
                if let data, let response {
                    continuation.resume(with: .success((data, response)))
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }.resume()
        }
    }
}
