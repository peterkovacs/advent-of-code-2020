
import Foundation
import ArgumentParser
import Algorithms

extension Coordinate {
    func slope(right: Int, down: Int, maxX: Int) -> Coordinate {
        var coordinate = self

        (0..<right).forEach { _ in coordinate = coordinate.right }
        (0..<down).forEach { _ in coordinate = coordinate.down }

        if coordinate.x >= maxX {
            coordinate = Coordinate(x: coordinate.x - maxX, y: coordinate.y)
        }

        return coordinate
    }
}

struct Day3: ParsableCommand {
    static let input = Array(stdin)
    static let grid: Grid<Character> = Grid(input.joined(), maxX: input[0].count, maxY: input.count)!

    func count(right: Int, down: Int) -> Int {
        var trees = 0
        var coordinate = Coordinate(x: 0, y: 0)

        while coordinate.isValid(x: Self.grid.maxX, y: Self.grid.maxY) {
            if Self.grid[coordinate] == "#" {
                trees += 1
            }

            coordinate = coordinate.slope(right: right, down: down, maxX: Self.grid.maxX)
        }

        return trees
    }

    func run() {
        print("Part 1", count(right: 3, down: 1))
        print("Part 2", [ (1, 1), (3, 1), (5, 1), (7, 1), (1, 2) ].map(count(right:down:)).reduce(1, *))
    }
}
