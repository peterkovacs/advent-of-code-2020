
import Foundation
import ArgumentParser
import Algorithms

fileprivate var neighbors = [Coordinate:[Coordinate]]()

fileprivate extension Grid where Element == Character {
    func neighborsNonFloor(_ coordinate: Coordinate) -> [Coordinate] {
        if let precalculated = neighbors[coordinate] { return precalculated }

        let result =
            [
                coordinate.go(in: \.left) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.right) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.up) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.down) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.up.left) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.up.right) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.down.left) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
                coordinate.go(in: \.down.right) { $0.isValid(x: maxX, y: maxY) && self[$0] == "." },
            ]
            .filter { $0.isValid(x: maxX, y: maxY) }

        neighbors[coordinate] = result
        return result
    }

    func tick() -> Self {
        var result = self

        for i in result.indices {
            if self[i] == "#", i.neighbors8(maxX: maxX, maxY: maxY).filter({ self[$0] == "#" }).count > 3 {
                result[i] = "L"
            }
            else if self[i] == "L", i.neighbors8(maxX: maxX, maxY: maxY).filter({ self[$0] == "#" }).isEmpty {
                result[i] = "#"
            }
        }

        return result
    }

    func tick2() -> Self {
        var result = self

        for i in result.indices {
            if self[i] == "#", neighborsNonFloor(i).filter({ self[$0] == "#" }).count > 4 {
                result[i] = "L"
            }
            else if self[i] == "L", neighborsNonFloor(i).filter({ self[$0] == "#" }).isEmpty {
                result[i] = "#"
            }
        }

        return result

    }
}

struct Day11: ParsableCommand {
    static let input = Array(stdin)
    static let grid: Grid<Character> = Grid(input.joined(), maxX: input[0].count, maxY: input.count)!

    func part1() {
        var prev = Self.grid
        var next = prev.tick()

        while !prev.elementsEqual(next) {
            prev = next
            next = next.tick()
        }

        print("Part 1", next.filter({ $0 == "#" }).count)
    }

    func part2() {
        var prev = Self.grid
        var next = prev.tick2()

        while !prev.elementsEqual(next) {
            prev = next
            next = next.tick2()
        }

        print("Part 2", next.filter({ $0 == "#" }).count)
    }

    func run() throws {
        part1()
        part2()
    }
}
