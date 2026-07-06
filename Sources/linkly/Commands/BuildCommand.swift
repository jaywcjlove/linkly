import ArgumentParser
import Foundation

struct Build: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Read linkly.json and generate output directory with index.html and assets"
    )

    @Option(name: .shortAndLong, help: "Project directory containing linkly.json")
    var directory: String?

    @Option(name: .shortAndLong, help: "Output directory (default: .html)")
    var output: String?

    func run() throws {
        let projectDir = ConfigManager.workingDirectory(from: directory)
        let config = try ConfigManager.load(from: projectDir)
        let result = try BuildService.build(config: config, projectDir: projectDir, output: output)

        print("✅ Built \(result.outputDirectory.path)")
        print("   HTML:   \(result.htmlPath.path)")
        print("   Links:  \(config.links.count)")
        print("   Theme:  \(config.site.theme)")
        print("   Assets: \(result.copiedAssets.count) raster, \(result.inlinedIcons.count) svg inlined")

        if !result.copiedAssets.isEmpty {
            for asset in result.copiedAssets.sorted() {
                print("     ✓ \(asset)")
            }
        }

        if !result.inlinedIcons.isEmpty {
            for asset in result.inlinedIcons.sorted() {
                print("     ◦ \(asset) (inlined)")
            }
        }

        if !result.missingAssets.isEmpty {
            print("   Missing assets:")
            for asset in result.missingAssets.sorted() {
                print("     ⚠ \(asset)")
            }
        }
    }
}