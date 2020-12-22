
import Foundation
import ArgumentParser
import Algorithms
import Parsing

var stdinStream = AnyIterator { readLine(strippingNewline: false).map { $0[...] } }

struct Day21: ParsableCommand {
    static let p = Many(
        Prefix<Substring>(minLength: 1) { $0 != " " && $0 != "(" },
        into: Set(),
        separator: StartsWith(" ")
    ) { $0.insert(String($1)) }
    .skip(StartsWith(" (contains "))
    .take(
        Many(
            Prefix<Substring>(minLength: 1) { $0 != "," && $0 != ")" },
            into: Set(),
            separator: StartsWith(", ")
        ) { $0.insert(String($1)) }
    )
    .skip(StartsWith(")"))
    .skip(Newline().pullback(\.utf8))
    .skip(End())

    static let input = p.stream.parse(&stdinStream) ?? []
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

//            print(Self.allergens.values.filter({ $0.count > 1 }))
        }

        print("Part 2", Self.allergens.sorted(by: { $0.key < $1.key }).flatMap(\.value).joined(separator: ","))
    }
}
