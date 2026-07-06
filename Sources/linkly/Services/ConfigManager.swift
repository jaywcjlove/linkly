import Foundation

enum ConfigManager {
    static let configFileName = "linkly.json"
    static let outputFileName = "index.html"

    static func configURL(in directory: URL) -> URL {
        directory.appendingPathComponent(configFileName)
    }

    static func workingDirectory(from path: String?) -> URL {
        if let path, !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    }

    static func load(from directory: URL) throws -> LinklyConfig {
        let url = configURL(in: directory)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LinklyError.configNotFound(url.path)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(LinklyConfig.self, from: data)
    }

    static func save(_ config: LinklyConfig, to directory: URL) throws {
        let url = configURL(in: directory)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(config)
        try data.write(to: url, options: .atomic)
    }

    static func htmlURL(in directory: URL) -> URL {
        directory.appendingPathComponent(outputFileName)
    }
}

enum LinklyError: LocalizedError {
    case configNotFound(String)
    case configAlreadyExists(String)
    case htmlNotFound(String)
    case invalidURL(String)
    case templateNotFound(String)
    case templateBundleNotFound
    case templateAlreadyExists(String)
    case templateRenderFailed
    case notAGitRepository(String)
    case gitRemoteNotFound(String)
    case gitCommandFailed(String, String)

    var errorDescription: String? {
        switch self {
        case .configNotFound(let path):
            return "Configuration file not found: \(path). Run 'linkly init' first."
        case .configAlreadyExists(let path):
            return "Configuration file already exists: \(path)"
        case .htmlNotFound(let path):
            return "HTML file not found: \(path). Run 'linkly build' first."
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .templateNotFound(let path):
            return "Template not found: \(path). Run 'linkly template eject' to customize templates."
        case .templateBundleNotFound:
            return "Bundled templates not found in Linkly package resources."
        case .templateAlreadyExists(let path):
            return "Template already exists: \(path). Use --force to overwrite."
        case .templateRenderFailed:
            return "Failed to render Leaf template."
        case .notAGitRepository(let path):
            return "Not a git repository: \(path)"
        case .gitRemoteNotFound(let remote):
            return "Git remote not found: \(remote)"
        case .gitCommandFailed(let command, let output):
            if output.isEmpty {
                return "Git command failed: \(command)"
            }
            return "Git command failed: \(command)\n\(output)"
        }
    }
}