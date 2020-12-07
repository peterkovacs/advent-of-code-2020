
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

let word = oneOrMore(alphanumeric)

struct Day7: ParsableCommand {
    // shiny indigo bags contain 4 vibrant lime bags.
    // clear lime bags contain 1 dotted lime bag, 2 clear gold bags.

    static let parser =
        oneOrMore(
            tuple <^>
                (curry { String("\($0) \($1)") } <^> word <*> (whitespace *> word)) <*>
                (
                    string(" bags contain ") *> (
                        oneOrMore(
                            tuple <^>
                                (integer <* whitespace) <*>
                                (curry { String("\($0) \($1)") } <^> word <*> (whitespace *> word)) <*
                                (string(" bags") <|> string(" bag")) <* optional(string(", "))
                        ) <|>
                        string("no other bags") >>- { _ in pure([]) }
                    )
                ) <*
            char(".")
        )

    static let input = Dictionary(uniqueKeysWithValues: try! FootlessParser.parse(Self.parser, stdin.joined()))
    static var bagCounts: [ String: Int ] = [:]

    func contained(_ key: String) -> Int {
        if let count = Self.bagCounts[key] { return count }
        let count = Self.input[key]!.map { $0.0 * self.contained($0.1) }.sum + 1
        Self.bagCounts[key] = count
        return count
    }

    func part1() {
        var bagsContainingShinyGold = Set<String>(["shiny gold"])

        var didSomething = true
        while didSomething {
            didSomething = false
            Self.input
                .filter { color, _ in !bagsContainingShinyGold.contains(color) }
                .forEach { color, contained in
                    if contained.contains(where: { bagsContainingShinyGold.contains($0.1) }) {
                        bagsContainingShinyGold.insert(color)
                        didSomething = true
                    }
                }
        }

        print("Part 1", bagsContainingShinyGold.count - 1)
    }

    func run() {
        part1()
        print("Part 2", contained("shiny gold") - 1)
    }
}
