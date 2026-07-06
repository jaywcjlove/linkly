import ArgumentParser
import Foundation

struct Preview: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "preview",
        abstract: "Build output directory and open index.html in the default browser"
    )

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory (default: .html)")
    var output: String?

    func run() throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        let config = try ConfigManager.load(from: projectDir)
        let result = try BuildService.build(config: config, projectDir: projectDir, output: output)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [result.htmlPath.path]

        try process.run()
        process.waitUntilExit()

        print("✅ Opened preview: \(result.htmlPath.path)")
    }
}