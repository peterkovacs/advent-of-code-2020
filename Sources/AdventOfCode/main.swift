import ArgumentParser

var stdin = AnyIterator { readLine() }

struct AdventOfCode: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    abstract: "AdventOfCode 2020", 
    subcommands: [Day1.self, Day2.self]
  )
}

AdventOfCode.main()
