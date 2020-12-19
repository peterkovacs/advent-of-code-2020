
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

struct Day19: ParsableCommand {
    enum Rule {
        case letter(Character)
        case sequence([Int])
        case alternation([Int], [Int])
    }

    static let parser = tuple <^>
        (
            oneOrMore(
                (
                    tuple <^>
                        (integer <* char(":")) <*>
                        (
                            (
                                curry(Rule.alternation) <^>
                                    oneOrMore( whitespaces *> integer ) <*>
                                    (string(" |") *> oneOrMore( whitespaces *> integer))
                            ) <|>
                            (
                                Rule.sequence <^>
                                oneOrMore( whitespaces *> integer )
                            ) <|>
                            (
                                Rule.letter <^>
                                    (string(" \"") *> (any() <* char("\"")))
                            )
                        )
                )
                <* char("\n")
            ) <* char("\n")
        ) <*>
        oneOrMore(oneOrMore(oneOf("ab")) <* optional(char("\n")))

    static let (_rules, input) = try! FootlessParser.parse(parser, stdin.joined(separator: "\n"))
    static let rules = Dictionary(uniqueKeysWithValues: _rules)
    static var parsers = rules.mapValues(\.parser)

    func run() throws {
        let part1 = Day19.input.compactMap { try? FootlessParser.parse( Self.parsers[0]!, $0 ) }.count
        print("Part 1", part1)

        /*
         Rule 0 is "8 11", and is the only place rules 8 and 11 are referenced.
         Rule 8 -> 42+
         Rule 11 -> 42 (Rule 11)* 31
         Therefore Rule 0 becomes (Rule 42){n} (Rule 31){m} where n < m, m > 1.
         */
        let part2 = (tuple <^> oneOrMore(Self.parsers[42]!) <*> oneOrMore(Self.parsers[31]!)) >>- { (a, b) in
            pure(a.count > b.count)
        }

        let result = Day19.input.filter { (try? FootlessParser.parse( part2, $0 )) == true }.count
        print("Part 2", result)

    }
}

extension Day19.Rule {
    var parser: Parser<Character, String> {
        switch self {
        case .letter(let a): return string("\(a)")
        case .sequence(let a):
            return .init { input in
                var input = input
                let output = try a.reduce(into: "") {
                    let (output, remainder) = try Day19.parsers[$1]!.parse(input)
                    $0.append(output)
                    input = remainder
                }

                return (output, input)
            }
        case .alternation(let a, let b):
            return Day19.Rule.sequence(a).parser <|> Day19.Rule.sequence(b).parser
        }
    }
}
