import Foundation

enum TemplateManager {
    static let defaultTemplateDirectoryName = "templates"
    static let templateFileName = "index.leaf"

    static func templateDirectoryPath(in config: LinklyConfig) -> String {
        config.template?.directory ?? "./\(defaultTemplateDirectoryName)"
    }

    static func customTemplateDirectory(projectDir: URL, config: LinklyConfig) -> URL {
        resolvePath(templateDirectoryPath(in: config), relativeTo: projectDir)
    }

    static func resolveTemplateDirectory(projectDir: URL, config: LinklyConfig) throws -> URL {
        let customDir = customTemplateDirectory(projectDir: projectDir, config: config)
        let customTemplate = customDir.appendingPathComponent(templateFileName)

        if FileManager.default.fileExists(atPath: customTemplate.path) {
            return customDir
        }

        guard let bundled = bundledTemplateDirectory() else {
            throw LinklyError.templateNotFound(customTemplate.path)
        }

        return bundled
    }

    static func bundledTemplateDirectory() -> URL? {
        if let url = Bundle.module.url(forResource: "index", withExtension: "leaf") {
            return url.deletingLastPathComponent()
        }

        if let resourceURL = Bundle.module.resourceURL {
            let candidates = [
                resourceURL.appendingPathComponent("Templates", isDirectory: true),
                resourceURL.appendingPathComponent("Resources/Templates", isDirectory: true),
                resourceURL,
            ]

            for candidate in candidates {
                let template = candidate.appendingPathComponent(templateFileName)
                if FileManager.default.fileExists(atPath: template.path) {
                    return candidate
                }
            }
        }

        return nil
    }

    static func eject(projectDir: URL, config: LinklyConfig, force: Bool) throws -> URL {
        guard let bundled = bundledTemplateDirectory() else {
            throw LinklyError.templateBundleNotFound
        }

        let destination = customTemplateDirectory(projectDir: projectDir, config: config)
        let destinationTemplate = destination.appendingPathComponent(templateFileName)

        if FileManager.default.fileExists(atPath: destinationTemplate.path), !force {
            throw LinklyError.templateAlreadyExists(destinationTemplate.path)
        }

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try copyTemplateFiles(from: bundled, to: destination)

        return destination
    }

    private static func copyTemplateFiles(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        let items = try fileManager.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)

        for item in items {
            let target = destination.appendingPathComponent(item.lastPathComponent)
            if fileManager.fileExists(atPath: target.path) {
                try fileManager.removeItem(at: target)
            }
            try fileManager.copyItem(at: item, to: target)
        }
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