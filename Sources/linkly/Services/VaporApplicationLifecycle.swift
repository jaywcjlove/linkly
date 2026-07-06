import Vapor

enum VaporApplicationLifecycle {
    static func withApplication<T>(
        _ body: (Application) async throws -> T
    ) async throws -> T {
        let app = try await Application.make(.development)
        do {
            let value = try await body(app)
            try await app.asyncShutdown()
            return value
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}