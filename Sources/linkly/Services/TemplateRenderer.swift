import Foundation
import Leaf
import LeafKit
import Vapor

enum TemplateRenderer {
    static func render(buildData: BuildData, templateDirectory: URL) throws -> String {
        try runAsync {
            try await renderAsync(buildData: buildData, templateDirectory: templateDirectory)
        }
    }

    static func renderAsync(buildData: BuildData, templateDirectory: URL) async throws -> String {
        let app = try await Application.make(.development)
        defer { app.shutdown() }

        try configureLeaf(on: app, templateDirectory: templateDirectory)

        let context = PageContextBuilder.make(from: buildData)
        let request = Request(application: app, on: app.eventLoopGroup.next())
        let view = try await request.view.render("index", context).get()
        let response = try await view.encodeResponse(for: request).get()

        guard let body = response.body.data else {
            throw LinklyError.templateRenderFailed
        }

        return String(decoding: body, as: UTF8.self)
    }

    static func configureLeaf(on app: Application, templateDirectory: URL) throws {
        app.views.use(.leaf)
        app.leaf.configuration.rootDirectory = templateDirectory.path

        if shouldUseMemorySource(for: templateDirectory) {
            let source = try MemoryLeafSource.loadTemplates(from: templateDirectory)
            app.leaf.sources = .singleSource(source)
        } else {
            app.leaf.sources = .singleSource(NIOLeafFiles(
                fileio: app.fileio,
                limits: [.toSandbox, .requireExtensions],
                sandboxDirectory: templateDirectory.path,
                viewDirectory: templateDirectory.path
            ))
        }
    }

    private static func shouldUseMemorySource(for directory: URL) -> Bool {
        directory.path.contains("/.build/")
    }

    private static func runAsync<T>(_ operation: @escaping () async throws -> T) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var outcome: Result<T, Error>?

        Task {
            do {
                outcome = .success(try await operation())
            } catch {
                outcome = .failure(error)
            }
            semaphore.signal()
        }

        semaphore.wait()
        return try outcome!.get()
    }
}