import ArgumentParser
import Foundation

struct Template: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "template",
        abstract: "Manage Leaf templates",
        subcommands: [TemplateEject.self]
    )
}

struct TemplateEject: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "eject",
        abstract: "Copy bundled Leaf templates to your project for customization"
    )

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .long, help: "Template directory override (default: from linkly.json)")
    var templateDirectory: String?

    @Flag(name: .long, help: "Overwrite existing templates")
    var force: Bool = false

    func run() throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        var config = try ConfigManager.load(from: projectDir)

        if let templateDirectory, !templateDirectory.isEmpty {
            if config.template == nil {
                config.template = LinklyConfig.Template(directory: templateDirectory)
            } else {
                config.template?.directory = templateDirectory
            }
            try ConfigManager.save(config, to: projectDir)
        }

        let destination = try TemplateManager.eject(
            projectDir: projectDir,
            config: config,
            force: force
        )

        print("✅ Ejected templates to \(destination.path)")
        print("   Edit index.leaf to customize your page layout")
        print("   Run 'linkly build' or 'linkly serve' to apply changes")
    }
}