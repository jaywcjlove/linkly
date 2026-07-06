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
            let templateDirectory = try TemplateManager.resolveTemplateDirectory(
                projectDir: projectDir,
                config: config
            )

            try TemplateRenderer.configureLeaf(on: app, templateDirectory: templateDirectory)

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
                    templateDirectory: templateDirectory
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
            print("   Template: \(templateDirectory.path)")
            print("   Assets:   \(outputDir.path)")
            print("   Press Ctrl+C to stop")

            try await app.execute()
        }
    }
}