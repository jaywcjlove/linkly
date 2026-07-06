import Foundation

enum TemplateSource {
    case embedded
    case directory(URL)

    var displayPath: String {
        switch self {
        case .embedded:
            return "embedded"
        case let .directory(url):
            return url.path
        }
    }
}

enum TemplateManager {
    static let defaultTemplateDirectoryName = "templates"
    static let templateFileName = "index.leaf"

    static func templateDirectoryPath(in config: LinklyConfig) -> String {
        config.template?.directory ?? "./\(defaultTemplateDirectoryName)"
    }

    static func customTemplateDirectory(projectDir: URL, config: LinklyConfig) -> URL {
        resolvePath(templateDirectoryPath(in: config), relativeTo: projectDir)
    }

    static func resolveTemplateSource(projectDir: URL, config: LinklyConfig) -> TemplateSource {
        let customDirectory = customTemplateDirectory(projectDir: projectDir, config: config)
        let customTemplate = customDirectory.appendingPathComponent(templateFileName)

        if FileManager.default.fileExists(atPath: customTemplate.path) {
            return .directory(customDirectory)
        }

        return .embedded
    }

    static func eject(projectDir: URL, config: LinklyConfig, force: Bool) throws -> URL {
        let destination = customTemplateDirectory(projectDir: projectDir, config: config)
        let destinationTemplate = destination.appendingPathComponent(templateFileName)

        if FileManager.default.fileExists(atPath: destinationTemplate.path), !force {
            throw LinklyError.templateAlreadyExists(destinationTemplate.path)
        }

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        for (fileName, content) in EmbeddedResources.templates {
            let target = destination.appendingPathComponent(fileName)
            try content.write(to: target, atomically: true, encoding: .utf8)
        }

        return destination
    }

    private static func resolvePath(_ path: String, relativeTo projectDir: URL) -> URL {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("/") {
            return URL(fileURLWithPath: trimmed, isDirectory: true).standardizedFileURL
        }

        let relative = trimmed.hasPrefix("./") ? String(trimmed.dropFirst(2)) : trimmed
        return projectDir.appendingPathComponent(relative, isDirectory: true).standardizedFileURL
    }
}
