import Foundation

struct BuildData {
    let config: LinklyConfig
    let avatar: AvatarRender
    let links: [LinkRender]
}

enum AvatarRender {
    case image(src: String)
    case inlineSVG(String)
    case placeholder(initial: String)
}

struct LinkRender {
    let label: String
    let url: String
    let icon: LinkIconRender
}

enum LinkIconRender {
    case inlineSVG(String)
    case image(src: String)
    case placeholder(initial: String)
}

struct BuildAssetStats {
    var copiedAssets: [String] = []
    var inlinedIcons: [String] = []
    var missingAssets: [String] = []
}