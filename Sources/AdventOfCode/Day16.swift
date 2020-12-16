
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

struct Day16: ParsableCommand {
    static let range = ( curry { $0...$1 } <^> integer <*> (char("-") *> integer) )
    static let parser = tuple <^>
        oneOrMore(
            tuple <^> (
                oneOrMore(not(":")) <* string(": ")
            ) <*>
            range <*>
            (
                (string(" or ") *> range) <* char("\n")
            )
        ) <*>
        ( string("\nyour ticket:\n") *> oneOrMore(integer <* optional(char(","))) <* whitespacesOrNewline ) <*>
        ( string("\nnearby tickets:\n") *> oneOrMore( oneOrMore(integer <* optional(char(","))) <* whitespacesOrNewline ))

    func run() throws {
        let (rules, yourTicket, nearbyTickets) = try FootlessParser.parse( Self.parser, stdin.joined(separator: "\n"))

        let errorRate = nearbyTickets.reduce(into: 0) { result, ticket in
            result += ticket.filter { value in !rules.contains(where: { $0.1.contains(value) || $0.2.contains(value) }) }.sum
        }

        print("Part 1", errorRate)

        let validTickets = nearbyTickets.filter {
            $0.allSatisfy { value in
                rules.contains(where: { $0.1.contains(value) || $0.2.contains(value) })
            }
        }

        var proposition = rules.enumerated().map { (i, rule) -> Set<Int> in
            let (_, a, b) = rule

            return validTickets.reduce(into: Set(yourTicket.indices)) { result, ticket in
                ticket.indexed().forEach {
                    if !a.contains($0.element) && !b.contains($0.element) {
                        result.remove($0.index)
                    }
                }
            }
        }

        // Resolve the proposition by removing any field that definitely maps to a single rule from all other rules.
        while !proposition.allSatisfy({ $0.count == 1 }) {
            let remove = proposition.filter { $0.count == 1 }.reduce(into: Set()) { $0.formUnion($1) }
            for (i, set) in proposition.indexed() where set.count > 1 {
                proposition[i] = set.subtracting(remove)
            }
        }

        let product = rules.enumerated().filter {
            $0.element.0.starts(with: "departure")
        }
        .map {
            yourTicket[ proposition[ $0.offset ].first! ]
        }
        .product

        print("Part 2", product)
    }
}
