import ArgumentParser
import Foundation

struct Deploy: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "deploy",
        abstract: "Commit the output directory to the local gh-pages branch"
    )

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory to deploy (default: .html)")
    var output: String?

    @Option(name: .long, help: "Git branch to deploy (default: gh-pages)")
    var branch: String = GitHubPagesDeployer.defaultBranch

    @Option(name: .long, help: "Git remote name (default: origin)")
    var remote: String = GitHubPagesDeployer.defaultRemote

    @Option(name: .shortAndLong, help: "Git commit message")
    var message: String = "Deploy site"

    @Flag(name: .long, help: "Build HTML before deploy")
    var build: Bool = false

    func run() throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        let outputDir = BuildService.resolveOutputDirectory(projectDir: projectDir, output: output)

        if build {
            let config = try ConfigManager.load(from: projectDir)
            _ = try BuildService.build(config: config, projectDir: projectDir, output: output)
        }

        try GitHubPagesDeployer.deploy(
            projectDir: projectDir,
            outputDir: outputDir,
            branch: branch,
            remote: remote,
            message: message
        )
    }
}