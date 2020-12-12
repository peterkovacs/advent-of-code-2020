
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

fileprivate extension KeyPath where Root == Coordinate, Value == Coordinate {
    static let parser: Parser<Character, Coordinate.Direction> = [
        "N": \Coordinate.north, "S": \Coordinate.south, "E": \Coordinate.east, "W": \Coordinate.west
    ].parser
}

fileprivate enum Command {
    case move(Coordinate.Direction, Int)
    // Negative is CCW, Positive is CW
    case turn(Int)
    case forward(Int)

    static let parser: Parser<Character, Command> =
        (curry({ Command.move($0, $1) }) <^> Coordinate.Direction.parser <*> integer) <|>
        ( { Command.turn(-1 * $0) } <^> (char("L") *> integer) ) <|>
        ( { Command.turn($0) } <^> (char("R") *> integer) ) <|>
        ( { Command.forward($0) } <^> (char("F") *> integer) )
}

fileprivate struct Ship {
    var facing: Coordinate.Direction
    var position: Coordinate
}

fileprivate struct Waypoint {
    var waypoint: Coordinate
    var ship: Coordinate
}


struct Day12: ParsableCommand {
    fileprivate static let input = stdin.compactMap { try? FootlessParser.parse(Command.parser, $0) }
    func run() {
        let part1 = Self.input.reduce(into: Ship(facing: \.east, position: .zero)) {
            switch $1 {
            case .move(let direction, let val):
                $0.position = $0.position.go(in: direction, val)
            case .forward(let val):
                $0.position = $0.position.go(in: $0.facing, val)
            case .turn(-90), .turn(270):  $0.facing = Coordinate.turn(left: $0.facing)
            case .turn(-180), .turn(180): $0.facing = Coordinate.turn(around: $0.facing)
            case .turn(-270), .turn(90):  $0.facing = Coordinate.turn(right: $0.facing)
            case .turn: fatalError()
            }
        }

        print("Part 1", abs(part1.position.x) + abs(part1.position.y))

        let part2 = Self.input.reduce(into: Waypoint(waypoint: .init(x: 10, y: 1), ship: .zero)) {
            let vector = $0.waypoint - $0.ship

            switch $1 {
            case .move(let direction, let value):
                $0.waypoint = $0.waypoint.go(in: direction, value)
            case .forward(let multiplier):
                $0.ship = $0.ship + vector * multiplier
                $0.waypoint = $0.waypoint + vector * multiplier
            case .turn(-90), .turn(270):
                $0.waypoint = $0.ship + Coordinate(x: -vector.y, y: vector.x)
            case .turn(-180), .turn(180):
                $0.waypoint = $0.ship + Coordinate(x: -vector.x, y: -vector.y)
            case .turn(-270), .turn(90):
                $0.waypoint = $0.ship + Coordinate(x: vector.y, y: -vector.x)
            case .turn: fatalError()
            }
        }

        print("Part 2", abs(part2.ship.x) + abs(part2.ship.y))
    }
}
