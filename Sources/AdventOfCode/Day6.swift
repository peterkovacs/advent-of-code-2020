
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

struct Day6: ParsableCommand {
    static let input = Array(stdin).joined(separator: "\n")
    static let parser =
        oneOrMore(
                oneOrMore(
                    ( oneOrMore(oneOf("abcdefghijklmnopqrstuvwxyz")) <* char("\n") )
                )
                <* optional(char("\n"))
        )
    func run() {
        let groups = try! FootlessParser.parse(Self.parser, Self.input)
        print("Part 1", groups.map { Set($0.joined()) }.map(\.count).sum)
        print("Part 2", groups.map { $0.reduce(Set("abcdefghijklmnopqrstuvwxyz")) { $0.intersection($1) }}.map(\.count).sum )
    }
}
