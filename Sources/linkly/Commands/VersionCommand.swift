import ArgumentParser

struct Version: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Show the linkly version number"
    )

    func run() {
        print("linkly \(LinklyVersion.current)")
    }
}