
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

fileprivate extension Grid where Element == String.Element {

    func isOn(offset: Int, x: Int, y: Int) -> Int {
        if self[x: x, y: y] == "#" {
            return 1 << offset
        } else {
            return 0
        }
    }

    var top: String {
        stride(from: 0, to: maxX, by: 1)
            .reduce(into: "") { $0.append(self[x: $1, y: 0]) }
    }

    var right: String {
        stride(from: 0, to: maxY, by: 1)
            .reduce(into: "") { $0.append(self[x: maxX - 1, y: $1]) }
    }

    var bottom: String {
        stride(from: 0, to: maxY, by: 1)
            .reduce(into: "") { $0.append(self[x: $1, y: maxY - 1]) }
    }

    var left: String {
        stride(from: 0, to: maxY, by: 1)
            .reduce(into: "") { $0.append(self[x: 0, y: $1]) }
    }

    private var rotations: [KeyPath<Self, Self>] {
        [
            \Self.self, \.rotated, \.rotated.rotated, \.rotated.rotated.rotated,
            \.mirrored, \.rotated.mirrored, \.rotated.rotated.mirrored, \.rotated.rotated.rotated.mirrored
        ]
    }

    var all: AnyIterator<Self> {
        var i = rotations.startIndex
        return .init {
            guard i != rotations.endIndex else { return nil }
            defer { rotations.formIndex(after: &i) }

            return self[keyPath: rotations[i]]
        }
    }

    var edges: [String] {
        [ top, right, bottom, left ]
    }

    func replacing(_ rhs: Self, with: Element, when element: Element) -> Self? {
        var result = self
        var found = false

        product( 0..<(maxX - rhs.maxX), 0..<(maxY - rhs.maxY)).forEach { (x, y) in
            let indices = rhs.indices
                .filter { rhs[$0] == element }
                .map { Coordinate(x: x, y: y) + $0 }

            if indices.allSatisfy({ result[$0] == element }) {
                found = true
                indices.forEach { result[$0] = with }
            }
        }

        return found ? result : nil
    }
}

struct Day20: ParsableCommand {
    static let parser = oneOrMore(
        tuple <^> (
            string("Tile ") *> (
                integer <* string(":\n")
            )
        ) <*>
        (
            oneOrMore(
                (
                    oneOrMore(
                        oneOf(".#")
                    ) <* char("\n")
                ) <*
                optional(char("\n"))
            ) >>- { pure(Grid($0.joined(), maxX: 10, maxY: 10)!) }
        )
    )

    static let input = try! FootlessParser.parse(parser, stdin.joined(separator: "\n"))

    func run() {
        let matches = Dictionary(uniqueKeysWithValues: Self.input.map { (id, grid) -> (Int, [Int]) in
            let edges = Set(grid.edges + grid.mirrored.edges)
            return ( id,
                Self.input
                    .lazy
                    .filter { $0.0 != id }
                    .filter { (i, p) in
                        p.edges.contains { edges.contains($0) } ||
                        p.mirrored.edges.contains { edges.contains($0) }
                    }
                    .map(\.0)
            )
        })

        let corners = matches.filter { $0.value.count == 2 }
        let pieces = Dictionary(uniqueKeysWithValues: Self.input)


        var puzzle = Grid<(id: Int, grid: Grid<Character>)?>(
            repeatElement(nil, count: pieces.count),
            maxX: Int(sqrt(Double(pieces.count))),
            maxY: Int(sqrt(Double(pieces.count)))
        )!

        func solve(position: Coordinate) {
            guard position.isValid(x: puzzle.maxX, y: puzzle.maxY) else { return }

            // The grid at `position`. Assumes that `grid` is already correctly oriented.
            let (id, grid) = puzzle[position]!
            // The pieces that match the grid at `position`.
            let partners = matches[id]!.flatMap { i in
                pieces[i]!.all.map {
                    (id: i, grid: $0)
                }
            }

            // Find the element of `partners` that belongs in each direction.
            if position.right.isValid(x: puzzle.maxX, y: puzzle.maxY),
               puzzle[position.right] == nil,
               let neighbor = partners.first(where: { $0.grid.left == grid.right }) {
                puzzle[position.right] = neighbor
                solve(position: position.right)
            }

            if position.down.isValid(x: puzzle.maxX, y: puzzle.maxY),
               puzzle[position.down] == nil,
               let neighbor = partners.first(where: { $0.grid.top == grid.bottom }) {
                puzzle[position.down] = neighbor
                solve(position: position.down)
            }

            if position.left.isValid(x: puzzle.maxX, y: puzzle.maxY),
               puzzle[position.left] == nil,
               let neighbor = partners.first(where: { $0.grid.right == grid.left }) {
                puzzle[position.left] = neighbor
                solve(position: position.left)
            }

            if position.up.isValid(x: puzzle.maxX, y: puzzle.maxY),
               puzzle[position.up] == nil,
               let neighbor = partners.first(where: { $0.grid.bottom == grid.top }) {
                puzzle[position.up] = neighbor
                solve(position: position.up)
            }
        }

        // Try each corner rotation at position 0,0 and see if we can solve the puzzle.
        for (id, grid) in corners.flatMap({ (id, _) in pieces[id]!.all.map { (key: id, grid: $0) } }) {
            guard !puzzle.filter({ $0 == nil }).isEmpty else { break }

            puzzle.grid = Array(repeatElement(nil, count: pieces.count))
            puzzle[.zero] = (id: id, grid: grid)
            solve(position: .zero)
        }

        precondition(puzzle.filter({ $0 == nil}).isEmpty)

        // transform into the actual grid.
        // grab the actual 8x8 grid out of each grid and map it into a 96x96 grid
        let pieceSize = (x: puzzle[.zero]!.grid.maxX - 2,
                         y: puzzle[.zero]!.grid.maxY - 2)
        let pictureSize = (x: pieceSize.x * puzzle.maxX,
                           y: pieceSize.y * puzzle.maxY)

        let picture = Grid(
            product(0..<pictureSize.x, 0..<pictureSize.y)
                .map { (x, y) -> Character in
                    let g = puzzle[x: x / pieceSize.x, y: y / pieceSize.y]!.grid
                    return g[x: (x % pieceSize.x) + 1, y: (y % pieceSize.y) + 1]
                },
            maxX: pictureSize.x,
            maxY: pictureSize.y
        )!

        let seaMonster = Grid(
                "                   # " +
                " #    ##    ##    ###" +
                "  #  #  #  #  #  #   ",
            maxX: 21,
            maxY: 3
        )!

        let result = Array(
            picture.all.lazy
                .compactMap { $0.replacing(seaMonster, with: "O", when: "#") }
                .prefix(1)
        )[0]


        // Find any Sea Monsters in the picture and turn them into `.`
        // May need to rotate / flip picture to find any.
        //                   #
        // #    ##    ##    ###
        //  #  #  #  #  #  #
        print("Part 1",
              puzzle[x: 0, y: 0]!.id *
              puzzle[x: 0, y: puzzle.maxY - 1]!.id *
              puzzle[x: puzzle.maxX - 1, y: puzzle.maxY - 1]!.id *
              puzzle[x: puzzle.maxX - 1, y: 0]!.id)
        print("Part 2", result.filter { $0 == "#" }.count)

        print(result)
    }
}
