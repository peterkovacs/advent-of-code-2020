
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

struct Day21: ParsableCommand {
    static let parser = tuple <^>
        (Set<String>.init <^> oneOrMore( oneOrMore(noneOf(" (")) <* whitespace )) <*>
        (
            string("(contains ") *> oneOrMore(oneOrMore(noneOf(",)")) <* optional(string(", "))) <* char(")")
        )
    static let input = stdin.map { try! FootlessParser.parse(parser, $0) }
    static var allergens = Dictionary(input.flatMap { a, b in b.map { ($0, a) } }) {
        $0.intersection($1)
    }
    static let allAllergens = allergens.values.reduce(into: Set()) { $0.formUnion($1) }
    static let nonAllergens = input.map(\.0).reduce(into: Set()) { $0.formUnion($1) }.subtracting(allAllergens)

    func run() {
        print("Part 1", Self.nonAllergens.map { ingredient in Self.input.filter { $0.0.contains(ingredient) }.count }.sum)

        while Self.allergens.values.contains(where: { $0.count > 1 }) {
            for (a, allergen) in Self.allergens where allergen.count == 1 {
                for (b, ingredients) in Self.allergens where b != a && ingredients.count > 1 {
                    Self.allergens[b] = ingredients.subtracting(allergen)
                }
            }
        }

        print("Part 2", Self.allergens.sorted(by: { $0.key < $1.key }).flatMap(\.value).joined(separator: ","))
    }
}
