
import Foundation
import ArgumentParser
import Algorithms

fileprivate extension Grid where Element == Character {
    func neighborsNonFloor(_ coordinate: Coordinate) -> [Coordinate] {
        var left = coordinate.left
        while left.isValid(x: maxX, y: maxY), self[left] == "." {
            left = left.left
        }

        var right = coordinate.right
        while right.isValid(x: maxX, y: maxY), self[right] == "." {
            right = right.right
        }

        var up = coordinate.up
        while up.isValid(x: maxX, y: maxY), self[up] == "." {
            up = up.up
        }

        var down = coordinate.down
        while down.isValid(x: maxX, y: maxY), self[down] == "." {
            down = down.down
        }

        var upLeft = coordinate.up.left
        while upLeft.isValid(x: maxX, y: maxY), self[upLeft] == "." {
            upLeft = upLeft.up.left
        }

        var upRight = coordinate.up.right
        while upRight.isValid(x: maxX, y: maxY), self[upRight] == "." {
            upRight = upRight.up.right
        }

        var downLeft = coordinate.down.left
        while downLeft.isValid(x: maxX, y: maxY), self[downLeft] == "." {
            downLeft = downLeft.down.left
        }

        var downRight = coordinate.down.right
        while downRight.isValid(x: maxX, y: maxY), self[downRight] == "." {
            downRight = downRight.down.right
        }

        return [ up, down, left, right, upLeft, upRight, downLeft, downRight].filter { $0.isValid(x: maxX, y: maxY)}
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
