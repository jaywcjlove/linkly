import Foundation

enum IconProcessor {
    static let assetsDirectoryName = "assets"

    private enum AssetFormat {
        case svg
        case raster
        case remote
        case unknown
    }

    static func prepareBuildData(
        config: LinklyConfig,
        projectDir: URL,
        outputDir: URL
    ) throws -> (BuildData, BuildAssetStats) {
        var stats = BuildAssetStats()
        let assetsDir = outputDir.appendingPathComponent(assetsDirectoryName, isDirectory: true)

        let avatar = try processAvatar(
            config.site.avatar,
            title: config.site.title,
            projectDir: projectDir,
            assetsDir: assetsDir,
            stats: &stats
        )

        let links = try config.links.map { link in
            try processLink(link, projectDir: projectDir, assetsDir: assetsDir, stats: &stats)
        }

        let buildData = BuildData(config: config, avatar: avatar, links: links)
        return (buildData, stats)
    }

    private static func processAvatar(
        _ path: String,
        title: String,
        projectDir: URL,
        assetsDir: URL,
        stats: inout BuildAssetStats
    ) throws -> AvatarRender {
        let initial = String(title.prefix(1))
        guard BuildService.isLocalAsset(path) else {
            return .placeholder(initial: initial)
        }

        let relativePath = normalizeRelativePath(path)
        guard !relativePath.isEmpty else {
            return .placeholder(initial: initial)
        }

        let source = projectDir.appendingPathComponent(relativePath)
        guard FileManager.default.fileExists(atPath: source.path) else {
            stats.missingAssets.append(relativePath)
            return .placeholder(initial: initial)
        }

        switch assetFormat(for: relativePath) {
        case .svg:
            let content = try String(contentsOf: source, encoding: .utf8)
            let inline = inlineSVG(content, className: "avatar")
            stats.inlinedIcons.append(relativePath)
            return .inlineSVG(inline)
        case .raster:
            let copied = try copyToAssets(source: source, relativePath: relativePath, assetsDir: assetsDir)
            stats.copiedAssets.append(copied)
            return .image(src: "./\(assetsDirectoryName)/\((copied as NSString).lastPathComponent)")
        case .remote, .unknown:
            stats.missingAssets.append(relativePath)
            return .placeholder(initial: initial)
        }
    }

    private static func processLink(
        _ link: LinklyConfig.Link,
        projectDir: URL,
        assetsDir: URL,
        stats: inout BuildAssetStats
    ) throws -> LinkRender {
        let initial = String(link.label.prefix(1))
        let icon = try resolveLinkIcon(
            link,
            initial: initial,
            projectDir: projectDir,
            assetsDir: assetsDir,
            stats: &stats
        )

        return LinkRender(label: link.label, url: link.url, icon: icon)
    }

    private static func resolveLinkIcon(
        _ link: LinklyConfig.Link,
        initial: String,
        projectDir: URL,
        assetsDir: URL,
        stats: inout BuildAssetStats
    ) throws -> LinkIconRender {
        if BundledIcons.isConfigured(link.icon) {
            guard let icon = link.icon else {
                return .placeholder(initial: initial)
            }

            if icon.lowercased().hasPrefix("http://") || icon.lowercased().hasPrefix("https://") {
                return .image(src: icon)
            }

            guard BuildService.isLocalAsset(icon) else {
                return .placeholder(initial: initial)
            }

            let relativePath = normalizeRelativePath(icon)
            let source = projectDir.appendingPathComponent(relativePath)

            guard FileManager.default.fileExists(atPath: source.path) else {
                stats.missingAssets.append(relativePath)
                return .placeholder(initial: initial)
            }

            return try processLocalIcon(
                source: source,
                relativePath: relativePath,
                initial: initial,
                assetsDir: assetsDir,
                stats: &stats
            )
        }

        guard let iconName = BundledIcons.resolveIconName(for: link),
              let content = BundledIcons.content(for: iconName)
        else {
            return .placeholder(initial: initial)
        }

        let inline = inlineSVG(content, className: "link-icon")
        stats.inlinedIcons.append("\(iconName).svg")
        return .inlineSVG(inline)
    }

    private static func processLocalIcon(
        source: URL,
        relativePath: String,
        initial: String,
        assetsDir: URL,
        stats: inout BuildAssetStats
    ) throws -> LinkIconRender {
        switch assetFormat(for: relativePath) {
        case .svg:
            let content = try String(contentsOf: source, encoding: .utf8)
            let inline = inlineSVG(content, className: "link-icon")
            stats.inlinedIcons.append(relativePath)
            return .inlineSVG(inline)
        case .raster:
            let copied = try copyToAssets(source: source, relativePath: relativePath, assetsDir: assetsDir)
            stats.copiedAssets.append(copied)
            return .image(src: "./\(assetsDirectoryName)/\((copied as NSString).lastPathComponent)")
        case .remote, .unknown:
            stats.missingAssets.append(relativePath)
            return .placeholder(initial: initial)
        }
    }

    private static func copyToAssets(source: URL, relativePath: String, assetsDir: URL) throws -> String {
        if !FileManager.default.fileExists(atPath: assetsDir.path) {
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
        }

        let fileName = (relativePath as NSString).lastPathComponent
        let destination = assetsDir.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        try FileManager.default.copyItem(at: source, to: destination)
        return "\(assetsDirectoryName)/\(fileName)"
    }

    static func inlineSVG(_ content: String, className: String) -> String {
        var svg = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if let range = svg.range(of: #"<\?xml[^>]*\?>"#, options: .regularExpression) {
            svg.removeSubrange(range)
        }
        if let range = svg.range(of: #"<!DOCTYPE[^>]*>"#, options: [.regularExpression, .caseInsensitive]) {
            svg.removeSubrange(range)
        }

        svg = svg.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let svgRange = svg.range(of: "<svg", options: .caseInsensitive) else {
            return svg
        }

        let headerEnd = svg.index(svgRange.upperBound, offsetBy: 200, limitedBy: svg.endIndex) ?? svg.endIndex
        let header = svg[svgRange.lowerBound..<headerEnd]

        if header.range(of: "class=", options: .caseInsensitive) == nil {
            svg.insert(contentsOf: " class=\"\(className)\"", at: svgRange.upperBound)
        }

        return svg.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func assetFormat(for path: String) -> AssetFormat {
        let ext = (path as NSString).pathExtension.lowercased()
        switch ext {
        case "svg":
            return .svg
        case "png", "jpg", "jpeg", "webp", "gif", "ico":
            return .raster
        default:
            return .unknown
        }
    }

    private static func normalizeRelativePath(_ path: String) -> String {
        var normalized = path.trimmingCharacters(in: .whitespacesAndNewlines)
        while normalized.hasPrefix("./") {
            normalized = String(normalized.dropFirst(2))
        }
        while normalized.hasPrefix("/") {
            normalized = String(normalized.dropFirst())
        }
        return normalized
    }
}
