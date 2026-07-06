import Foundation

enum GitHubPagesDeployer {
    static let defaultBranch = "gh-pages"

    static func deploy(
        projectDir: URL,
        outputDir: URL,
        branch: String,
        message: String
    ) throws {
        let gitDir = projectDir.appendingPathComponent(".git")
        guard FileManager.default.fileExists(atPath: gitDir.path) else {
            throw LinklyError.notAGitRepository(projectDir.path)
        }

        let htmlPath = ConfigManager.htmlURL(in: outputDir)
        guard FileManager.default.fileExists(atPath: htmlPath.path) else {
            throw LinklyError.htmlNotFound(htmlPath.path)
        }

        let currentBranch = try GitRunner.currentBranch(in: projectDir)
        defer {
            if currentBranch != branch {
                _ = try? GitRunner.run("checkout", currentBranch, in: projectDir)
            }
        }

        if GitRunner.branchExists(branch, in: projectDir) {
            try GitRunner.run("checkout", branch, in: projectDir)
        } else {
            try GitRunner.run("checkout", "--orphan", branch, in: projectDir)
        }

        try GitRunner.run("rm", "-rf", "--ignore-unmatch", ".", in: projectDir)
        try clearWorkingTree(in: projectDir)
        try copyOutputContents(from: outputDir, to: projectDir)

        let noJekyll = projectDir.appendingPathComponent(".nojekyll")
        try Data().write(to: noJekyll)

        try GitRunner.run("add", "-A", in: projectDir)

        let status = try GitRunner.output("status", "--porcelain", in: projectDir)
        if status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("ℹ️  No changes to deploy")
            return
        }

        try GitRunner.run("commit", "-m", message, in: projectDir)

        print("✅ Committed to local branch \(branch)")
        print("   Source: \(outputDir.path)")
        print("   Push manually: git push origin \(branch)")
    }

    private static func clearWorkingTree(in projectDir: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(
            at: projectDir,
            includingPropertiesForKeys: nil,
            options: []
        )

        for item in contents where item.lastPathComponent != ".git" {
            try fileManager.removeItem(at: item)
        }
    }

    private static func copyOutputContents(from outputDir: URL, to projectDir: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(
            at: outputDir,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        for item in contents {
            let destination = projectDir.appendingPathComponent(item.lastPathComponent)
            try fileManager.copyItem(at: item, to: destination)
        }
    }
}

enum GitRunner {
    @discardableResult
    static func run(_ arguments: String..., in directory: URL) throws -> String {
        try run(arguments: arguments, in: directory)
    }

    @discardableResult
    static func run(arguments: [String], in directory: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = directory

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            let command = (["git"] + arguments).joined(separator: " ")
            throw LinklyError.gitCommandFailed(command, output.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return output
    }

    static func output(_ arguments: String..., in directory: URL) throws -> String {
        try run(arguments: arguments, in: directory)
    }

    static func currentBranch(in directory: URL) throws -> String {
        try output("rev-parse", "--abbrev-ref", "HEAD", in: directory)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func branchExists(_ branch: String, in directory: URL) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["show-ref", "--verify", "--quiet", "refs/heads/\(branch)"]
        process.currentDirectoryURL = directory
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return false
        }

        process.waitUntilExit()
        return process.terminationStatus == 0
    }
}