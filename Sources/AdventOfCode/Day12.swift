
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser
import Numerics

fileprivate extension Complex where RealType == Double {
    static let parser: Parser<Character, Self> = [
        "N": Self.i, "S": Self.i * Self(-1.0), "E": Self(1.0), "W": Self(-1.0)
    ].parser
}

fileprivate enum Command {
    case move(Complex<Double>)
    case turn(Complex<Double>)
    case forward(Complex<Double>)

    static let parser: Parser<Character, Command> =
        (curry({ Command.move($0 * Complex(Double($1))) }) <^> Complex<Double>.parser <*> integer) <|>
        ((string("L90") <|> string("R270"))  >>- { _ in pure(Command.turn(.i)) })  <|>
        ((string("L180") <|> string("R180")) >>- { _ in pure(Command.turn(Complex(-1))) }) <|>
        ((string("L270") <|> string("R90"))  >>- { _ in pure(Command.turn(.i * Complex(-1))) }) <|>
        ( { Command.forward(Complex(Double($0))) } <^> (char("F") *> integer) )
}

fileprivate struct Ship {
    var facing: Complex<Double>
    var position: Complex<Double>
}

fileprivate struct Waypoint {
    var waypoint: Complex<Double>
    var ship: Complex<Double>
}

struct Day12: ParsableCommand {
    fileprivate static let input = stdin.compactMap { try? FootlessParser.parse(Command.parser, $0) }
    func run() {
        let part1 = Self.input.reduce(into: Ship(facing: Complex(1), position: .zero)) {
            switch $1 {
            case .move(let val): $0.position = $0.position + val
            case .forward(let val): $0.position = $0.position + $0.facing * val
            case .turn(let rotation): $0.facing = $0.facing * rotation
            }
        }

        print("Part 1", abs(part1.position.real) + abs(part1.position.imaginary))

        let part2 = Self.input.reduce(into: Waypoint(waypoint: .init(10.0, 1.0), ship: .zero)) {
            let vector = $0.waypoint - $0.ship

            switch $1 {
            case .move(let val): $0.waypoint = $0.waypoint + val
            case .forward(let multiplier):
                $0.ship = $0.ship + vector * multiplier
                $0.waypoint = $0.waypoint + vector * multiplier
            case .turn(let rotation): $0.waypoint = $0.ship + vector * rotation
            }
        }

        print("Part 2", abs(part2.ship.real) + abs(part2.ship.imaginary))
    }
}
