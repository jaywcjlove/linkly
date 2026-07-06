import ArgumentParser
import Foundation

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Build and start a Vapor server to preview your link page"
    )

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory for static assets (default: .html)")
    var output: String?

    @Option(name: .shortAndLong, help: "Port number")
    var port: UInt16 = 8080

    @Flag(name: .long, help: "Skip rebuilding assets before serving")
    var noBuild: Bool = false

    func run() async throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        let outputDir = BuildService.resolveOutputDirectory(projectDir: projectDir, output: output)
        let config = try ConfigManager.load(from: projectDir)

        if !noBuild {
            _ = try BuildService.build(config: config, projectDir: projectDir, output: output)
        } else if !FileManager.default.fileExists(atPath: outputDir.path) {
            throw LinklyError.htmlNotFound(outputDir.path)
        }

        try await VaporServer.start(
            projectDir: projectDir,
            outputDir: outputDir,
            config: config,
            port: port
        )
    }
}