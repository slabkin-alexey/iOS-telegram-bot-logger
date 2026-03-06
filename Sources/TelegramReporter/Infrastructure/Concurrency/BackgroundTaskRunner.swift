import Foundation

enum BackgroundTaskRunner {
    static func run<T: Sendable>(
        priority: TaskPriority = .utility,
        operation: @escaping @Sendable () throws -> T
    ) async throws -> T {
        try await Task.detached(priority: priority, operation: operation).value
    }
}
