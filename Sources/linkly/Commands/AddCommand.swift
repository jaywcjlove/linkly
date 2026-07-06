import ArgumentParser
import Foundation

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Quickly add a link to linkly.json"
    )

    @Argument(help: "Link label")
    var label: String

    @Argument(help: "Link URL")
    var url: String

    @Argument(help: "Icon path (optional, auto-detected from URL/label when omitted)")
    var icon: String?

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory when rebuilding (default: .html)")
    var output: String?

    @Flag(name: .long, help: "Rebuild output directory after adding")
    var build: Bool = false

    func run() throws {
        guard URL(string: url) != nil,
              url.hasPrefix("http://") || url.hasPrefix("https://") || url.hasPrefix("mailto:")
        else {
            throw LinklyError.invalidURL(url)
        }

        let projectDir = ConfigManager.workingDirectory(from: directory)
        var config = try ConfigManager.load(from: projectDir)

        let link = LinklyConfig.Link(label: label, url: url, icon: icon)
        config.links.append(link)
        try ConfigManager.save(config, to: projectDir)

        print("✅ Added link: \(label)")
        print("   URL:  \(url)")
        if BundledIcons.isConfigured(icon) {
            print("   Icon: \(icon!)")
        } else {
            let auto = BundledIcons.resolveIconName(for: link).map { "\($0).svg (auto)" } ?? "none"
            print("   Icon: \(auto)")
        }

        if build {
            let result = try BuildService.build(config: config, projectDir: projectDir, output: output)
            print("   Rebuilt: \(result.outputDirectory.path)")
        }
    }
}