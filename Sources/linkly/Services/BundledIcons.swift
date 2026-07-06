import Foundation

enum BundledIcons {
    private static var cachedIconNames: [String]?

    private static let ignoredTLDs: Set<String> = [
        "app", "be", "cc", "cn", "co", "com", "dev", "gg", "io", "jp",
        "me", "net", "org", "qq", "tv", "uk",
    ]

    static func isConfigured(_ icon: String?) -> Bool {
        guard let icon else { return false }
        return !icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func resolveIconName(for link: LinklyConfig.Link) -> String? {
        if let fromURL = iconName(fromURL: link.url) {
            return fromURL
        }
        return iconName(fromLabel: link.label)
    }

    static func availableIconNames() -> [String] {
        if let cachedIconNames {
            return cachedIconNames
        }

        let urls = Bundle.module.urls(forResourcesWithExtension: "svg", subdirectory: nil) ?? []
        let names = Array(Set(urls.map { ($0.lastPathComponent as NSString).deletingPathExtension.lowercased() })).sorted()
        cachedIconNames = names
        return names
    }

    static func bundledURL(for iconName: String) -> URL? {
        let name = iconName.lowercased()
        guard availableIconNames().contains(name) else { return nil }
        return Bundle.module.url(forResource: name, withExtension: "svg")
    }

    private static func iconName(fromURL urlString: String) -> String? {
        let lower = urlString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let icons = Set(availableIconNames())
        guard !icons.isEmpty else { return nil }

        if lower.hasPrefix("mailto:") {
            return icons.contains("email") ? "email" : nil
        }

        guard lower.hasPrefix("http://") || lower.hasPrefix("https://") else {
            return nil
        }

        guard let url = URL(string: urlString), var host = url.host?.lowercased() else {
            return nil
        }

        if host.hasPrefix("www.") {
            host = String(host.dropFirst(4))
        }

        if icons.contains(host) {
            return host
        }

        let compactHost = host.replacingOccurrences(of: ".", with: "")
        if icons.contains(compactHost) {
            return compactHost
        }

        let segments = host
            .split(separator: ".")
            .map(String.init)
            .filter { !ignoredTLDs.contains($0) }
            .sorted { $0.count > $1.count }

        for segment in segments where icons.contains(segment) {
            return segment
        }

        return icons.contains("website") ? "website" : nil
    }

    private static func iconName(fromLabel label: String) -> String? {
        let key = label
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")

        guard !key.isEmpty else { return nil }
        return availableIconNames().contains(key) ? key : nil
    }
}