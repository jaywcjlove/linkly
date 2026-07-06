import ArgumentParser
import Foundation

struct Init: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize linkly.json and build the default output directory"
    )

    @Option(name: .shortAndLong, help: "Project directory")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory (default: .html)")
    var output: String?

    func run() throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        let configURL = ConfigManager.configURL(in: projectDir)

        if FileManager.default.fileExists(atPath: configURL.path) {
            throw LinklyError.configAlreadyExists(configURL.path)
        }

        let config = LinklyConfig.defaultConfig
        try ConfigManager.save(config, to: projectDir)

        let result = try BuildService.build(config: config, projectDir: projectDir, output: output)

        print("✅ Initialized linkly project in \(projectDir.path)")
        print("   Created: linkly.json")
        print("   Output:  \(result.outputDirectory.path)")
        print("")
        print("Next steps:")
        print("  1. Edit linkly.json to customize your profile and links")
        print("  2. Add avatar image; leave icon empty to auto-use built-in logos")
        print("  3. Run 'linkly build' to regenerate the output directory")
        print("  4. Run 'linkly template eject' to customize the Leaf template")
        print("  5. Run 'linkly preview' or 'linkly serve' to preview")
    }
}