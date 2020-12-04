import ArgumentParser

var stdin = AnyIterator { readLine() }

struct AdventOfCode: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    abstract: "AdventOfCode 2020", 
    subcommands: [Day1.self, Day2.self, Day3.self, Day4.self]
  )
}

AdventOfCode.main()
