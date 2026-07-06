import Foundation
import Leaf
import LeafKit
import Vapor

enum TemplateRenderer {
    static func render(buildData: BuildData, templateSource: TemplateSource) throws -> String {
        try runAsync {
            try await renderAsync(buildData: buildData, templateSource: templateSource)
        }
    }

    static func renderAsync(buildData: BuildData, templateSource: TemplateSource) async throws -> String {
        try await VaporApplicationLifecycle.withApplication { app in
            try await renderOnApplication(app, buildData: buildData, templateSource: templateSource)
        }
    }

    static func renderOnApplication(
        _ app: Application,
        buildData: BuildData,
        templateSource: TemplateSource
    ) async throws -> String {
        try configureLeaf(on: app, templateSource: templateSource)

        let context = PageContextBuilder.make(from: buildData)
        let request = Request(application: app, on: app.eventLoopGroup.next())
        let view = try await request.view.render("index", context).get()
        let response = try await view.encodeResponse(for: request).get()

        guard let body = response.body.data else {
            throw LinklyError.templateRenderFailed
        }

        return String(decoding: body, as: UTF8.self)
    }

    static func configureLeaf(on app: Application, templateSource: TemplateSource) throws {
        app.views.use(.leaf)

        switch templateSource {
        case .embedded:
            app.leaf.sources = .singleSource(MemoryLeafSource.embedded())
        case let .directory(templateDirectory):
            app.leaf.configuration.rootDirectory = templateDirectory.path
            app.leaf.sources = .singleSource(NIOLeafFiles(
                fileio: app.fileio,
                limits: [.toSandbox, .requireExtensions],
                sandboxDirectory: templateDirectory.path,
                viewDirectory: templateDirectory.path
            ))
        }
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
