import Foundation
import LeafKit
import NIOCore

struct MemoryLeafSource: LeafSource {
    let files: [String: String]

    func file(template: String, escape: Bool, on eventLoop: any EventLoop) -> EventLoopFuture<ByteBuffer> {
        let path = Self.normalizedPath(for: template)

        guard let content = files[path] else {
            return eventLoop.makeFailedFuture(LeafError(.noTemplateExists(template)))
        }

        var buffer = ByteBuffer()
        buffer.writeString(content)
        return eventLoop.makeSucceededFuture(buffer)
    }

    static func loadTemplates(from directory: URL) throws -> MemoryLeafSource {
        var files: [String: String] = [:]
        let fileManager = FileManager.default
        let items = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

        for item in items where item.pathExtension.lowercased() == "leaf" {
            let content = try String(contentsOf: item, encoding: .utf8)
            let key = Self.normalizedPath(for: (item.lastPathComponent as NSString).deletingPathExtension)
            files[key] = content
        }

        guard files[Self.normalizedPath(for: "index")] != nil else {
            throw LinklyError.templateNotFound(directory.appendingPathComponent("index.leaf").path)
        }

        return MemoryLeafSource(files: files)
    }

    private static func normalizedPath(for template: String) -> String {
        var path = template
        if !path.hasSuffix(".leaf") {
            path += ".leaf"
        }
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        return path
    }
}