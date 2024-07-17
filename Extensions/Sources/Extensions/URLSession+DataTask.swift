import Foundation

public extension URLSession {

    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let dataTaskHolder = CancellableHolder<URLSessionDataTask>()
        return try await withTaskCancellationHandler(operation: {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                dataTaskHolder.value = self.dataTask(with: urlRequest) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                dataTaskHolder.value?.resume()
            }
        }, onCancel: {
            dataTaskHolder.cancel()
        })
    }
}

private final class CancellableHolder<T: Cancellable>: @unchecked Sendable {
    private var lock = NSRecursiveLock()
    private var innerCancellable: T?

    private func synced<Result>(_ action: () throws -> Result) rethrows -> Result {
        lock.lock()
        defer { lock.unlock() }
        return try action()
    }

    var value: T? {
        get { synced { innerCancellable } }
        set { synced { innerCancellable = newValue } }
    }

    func cancel() {
        synced { innerCancellable?.cancel() }
    }
}

private protocol Cancellable {
    func cancel()
}

extension URLSessionDataTask: Cancellable {}
