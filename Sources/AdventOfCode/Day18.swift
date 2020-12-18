
import Foundation
import ArgumentParser
import FootlessParser
import Algorithms

struct Day18: ParsableCommand {
    enum Expr {
        case num(Int)
        indirect case add(Expr, Expr)
        indirect case mul(Expr, Expr)
        indirect case paren(Expr)

        static var flat: Parser<Character, Expr> {
            let number         = Expr.num   <^> integer
            let paren          = Expr.paren <^> (char("(") *> (lazy(self.flat) <* char(")")))
            let term           = number <|> paren
            let op             = string(" + ") >>- { _ in pure(Expr.add) } <|>
                                 string(" * ") >>- { _ in pure(Expr.mul) }
            let expression     = curry { $1.reduce($0) { $1.0($0, $1.1) } } <^>
                term <*> oneOrMore( tuple <^> op <*> term )
            return expression <|> term
        }

        static var precedence: Parser<Character, Expr> {
            var term: Parser<Character, Expr>! = nil

            let number         = Expr.num <^> integer
            let paren          = Expr.paren <^> (char("(") *> (lazy(self.precedence) <* char(")")))
            let factor         = number <|> paren
            let addition       = curry(Expr.add) <^> factor <*> (string(" + ") *> lazy(term))
            term               = addition <|> factor
            let multiplication = curry(Expr.mul) <^> term <*> (string(" * ") *> lazy(self.precedence))

            return multiplication <|> term
        }

        var value: Int {
            switch self {
            case .num(let x):    return x
            case let .add(a, b): return a.value + b.value
            case let .mul(a, b): return a.value * b.value
            case let .paren(p):  return p.value
            }

        }
    }

    static let input = Array(stdin)

    func part1() throws {
        let output = try Self.input.map { try FootlessParser.parse(\.value <^> Expr.flat, $0) }.sum
        print("Part 1", output)
    }

    func part2() throws {
        let output = try Self.input.map { try FootlessParser.parse(\.value <^> Expr.precedence, $0) }.sum
        print("Part 2", output)

    }

    func run() throws {
        try part1()
        try part2()
    }
}
