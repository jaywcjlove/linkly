import ArgumentParser

@main
struct Linkly: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "linkly",
        abstract: "Generate beautiful link aggregation pages from linkly.json",
        version: LinklyVersion.current,
        subcommands: [
            Init.self,
            Build.self,
            Serve.self,
            Preview.self,
            Version.self,
            Add.self,
            Template.self,
        ],
        defaultSubcommand: nil
    )
}