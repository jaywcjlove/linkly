import Foundation

struct BuildResult {
    let outputDirectory: URL
    let htmlPath: URL
    let copiedAssets: [String]
    let inlinedIcons: [String]
    let missingAssets: [String]
}

enum BuildService {
    static let defaultOutputDirectoryName = ".html"

    static func resolveOutputDirectory(projectDir: URL, output: String?) -> URL {
        guard let output, !output.isEmpty else {
            return projectDir.appendingPathComponent(defaultOutputDirectoryName, isDirectory: true)
        }

        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("/") {
            return URL(fileURLWithPath: trimmed, isDirectory: true).standardizedFileURL
        }

        let relative = trimmed.hasPrefix("./") ? String(trimmed.dropFirst(2)) : trimmed
        return projectDir.appendingPathComponent(relative, isDirectory: true).standardizedFileURL
    }

    static func build(config: LinklyConfig, projectDir: URL, output: String?) throws -> BuildResult {
        let outputDir = resolveOutputDirectory(projectDir: projectDir, output: output)
        try prepareOutputDirectory(outputDir)

        let (buildData, stats) = try IconProcessor.prepareBuildData(
            config: config,
            projectDir: projectDir,
            outputDir: outputDir
        )

        let templateDirectory = try TemplateManager.resolveTemplateDirectory(
            projectDir: projectDir,
            config: config
        )
        let html = try TemplateRenderer.render(
            buildData: buildData,
            templateDirectory: templateDirectory
        )
        let htmlPath = outputDir.appendingPathComponent(ConfigManager.outputFileName)
        try html.write(to: htmlPath, atomically: true, encoding: .utf8)

        return BuildResult(
            outputDirectory: outputDir,
            htmlPath: htmlPath,
            copiedAssets: stats.copiedAssets,
            inlinedIcons: stats.inlinedIcons,
            missingAssets: stats.missingAssets
        )
    }

    private static func prepareOutputDirectory(_ outputDir: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: outputDir.path) {
            try fileManager.removeItem(at: outputDir)
        }
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
    }

    static func isLocalAsset(_ path: String) -> Bool {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let lower = trimmed.lowercased()
        return !lower.hasPrefix("http://")
            && !lower.hasPrefix("https://")
            && !lower.hasPrefix("mailto:")
            && !lower.hasPrefix("data:")
    }
}