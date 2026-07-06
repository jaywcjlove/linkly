import Foundation

struct LinklyConfig: Codable {
    var site: Site
    var template: Template?
    var links: [Link]

    struct Template: Codable {
        var directory: String?
    }

    struct Site: Codable {
        var title: String
        var bio: String
        var avatar: String
        var theme: String
        var primaryColor: String

        enum CodingKeys: String, CodingKey {
            case title, bio, avatar, theme
            case primaryColor = "primary_color"
        }
    }

    struct Link: Codable {
        var label: String
        var url: String
        var icon: String?
    }

    static let defaultConfig = LinklyConfig(
        site: Site(
            title: "小弟调调",
            bio: "macOS/iOS 开发者 | Open Source Maintainer",
            avatar: "./avatar.jpg",
            theme: "dark",
            primaryColor: "#00d572"
        ),
        template: Template(directory: "./templates"),
        links: [
            Link(
                label: "GitHub",
                url: "https://github.com/jaywcjlove",
                icon: nil
            ),
        ]
    )
}