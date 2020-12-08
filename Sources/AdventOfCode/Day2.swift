import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

public let unsignedInteger = { Int($0)! } <^> oneOrMore(digit)
public let integer = { Int($0)! } <^> (extend <^> (char("+") <|> char("-")) <*> oneOrMore(digit)) <|> unsignedInteger
public let whitespaces = oneOrMore(FootlessParser.whitespace)

struct Day2: ParsableCommand {

    struct Policy {
        let range: ClosedRange<Int>
        let letter: Character
        let password: String
    }

    static let parser =
        curry(Policy.init) <^>
        ( { $0.0...$0.1 } <^> (tuple <^> integer <*> (string("-") *> integer)) ) <*>
        ( whitespace *> (any() as Parser<Character, Character>) ) <*>
        ( string(": ") *> oneOrMore(any() as Parser<Character, Character>))
    static let input = Array(stdin.compactMap { try? FootlessParser.parse(parser, $0) })
    
    func run() {
        print("Part 1", Day2.input.filter(\.isPart1Valid).count)
        print("Part 2", Day2.input.filter(\.isPart2Valid).count)

    }
}

extension Day2.Policy {
    var isPart1Valid: Bool {
        range.contains( password.lazy.filter { $0 == letter }.count )
    }

    var isPart2Valid: Bool {
        let password = Array(self.password)
        let a = (password[range.lowerBound - 1] == letter)
        let b = (password[range.upperBound - 1] == letter)
        return (a || b) && (a != b)
    }
}
