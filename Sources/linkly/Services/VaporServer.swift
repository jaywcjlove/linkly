import Foundation
import Vapor

enum VaporServer {
    static func start(
        projectDir: URL,
        outputDir: URL,
        config: LinklyConfig,
        port: UInt16
    ) async throws {
        try await VaporApplicationLifecycle.withApplication { app in
            let templateSource = TemplateManager.resolveTemplateSource(
                projectDir: projectDir,
                config: config
            )

            try TemplateRenderer.configureLeaf(on: app, templateSource: templateSource)

            if FileManager.default.fileExists(atPath: outputDir.path) {
                app.middleware.use(FileMiddleware(publicDirectory: outputDir.path))
            }

            app.get { request async throws -> Response in
                let (buildData, _) = try IconProcessor.prepareBuildData(
                    config: config,
                    projectDir: projectDir,
                    outputDir: outputDir
                )

                let html = try await TemplateRenderer.renderOnApplication(
                    app,
                    buildData: buildData,
                    templateSource: templateSource
                )

                return Response(
                    status: .ok,
                    headers: HTTPHeaders([("Content-Type", "text/html; charset=utf-8")]),
                    body: .init(string: html)
                )
            }

            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = Int(port)

            print("🚀 Linkly server running at http://localhost:\(port)")
            print("   Project:  \(projectDir.path)")
            print("   Template: \(templateSource.displayPath)")
            print("   Assets:   \(outputDir.path)")
            print("   Press Ctrl+C to stop")

            try await app.execute()
        }
    }
}
