import Foundation

struct PageContext: Encodable {
    let title: String
    let bio: String
    let theme: String
    let primaryColor: String
    let avatarHTML: String
    let links: [LinkContext]
}

struct LinkContext: Encodable {
    let label: String
    let url: String
    let iconHTML: String
}

enum PageContextBuilder {
    static func make(from buildData: BuildData) -> PageContext {
        let site = buildData.config.site
        let theme = site.theme.lowercased() == "light" ? "light" : "dark"

        return PageContext(
            title: site.title,
            bio: site.bio,
            theme: theme,
            primaryColor: sanitizeColor(site.primaryColor),
            avatarHTML: renderAvatar(buildData.avatar, title: site.title),
            links: buildData.links.map { link in
                LinkContext(
                    label: link.label,
                    url: link.url,
                    iconHTML: renderLinkIcon(link.icon)
                )
            }
        )
    }

    private static func renderAvatar(_ avatar: AvatarRender, title: String) -> String {
        switch avatar {
        case .image(let src):
            let escapedPath = escapeHTML(src)
            return """
            <img class="avatar" src="\(escapedPath)" alt="\(escapeHTML(title))" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
            <div class="avatar-placeholder" style="display:none">\(escapeHTML(String(title.prefix(1))))</div>
            """
        case .inlineSVG(let svg):
            return svg
        case .placeholder(let initial):
            return "<div class=\"avatar-placeholder\">\(escapeHTML(initial))</div>"
        }
    }

    private static func renderLinkIcon(_ icon: LinkIconRender) -> String {
        switch icon {
        case .inlineSVG(let svg):
            return svg
        case .image(let src):
            return "<img class=\"link-icon\" src=\"\(escapeHTML(src))\" alt=\"\">"
        case .placeholder(let initial):
            return "<span class=\"link-icon-placeholder\">\(escapeHTML(initial))</span>"
        }
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func sanitizeColor(_ color: String) -> String {
        let trimmed = color.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexPattern = #"^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"#
        if trimmed.range(of: hexPattern, options: .regularExpression) != nil {
            return trimmed
        }
        return "#00ff88"
    }
}