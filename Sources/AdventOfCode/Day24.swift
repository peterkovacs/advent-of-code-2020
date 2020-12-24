
import Foundation
import ArgumentParser
import Algorithms
import Parsing

extension Coordinate {
    static let hexNeighbors = [(1, 1), (-1, 1), (1, -1), (-1, -1), (-2, 0), (2, 0)].map(Coordinate.init)

    var hexNeighbors: [Coordinate] {
        Self.hexNeighbors.map { self + $0 }
    }
}

extension Dictionary where Key == Coordinate, Value == Bool {
    func step() -> Self {
        let blackTiles = Set(filter(\.value).keys)
        let whiteTiles = Set(blackTiles.flatMap(\.hexNeighbors)).subtracting(blackTiles)

        return .init(
            uniqueKeysWithValues:
                blackTiles.filter {
                    (1...2).contains(Set($0.hexNeighbors).intersection(blackTiles).count)
                }.union(
                    whiteTiles.filter {
                        Set($0.hexNeighbors).intersection(blackTiles).count == 2
                    }
                )
                .map({ ($0, true) })
        )
    }
}

struct Day24: ParsableCommand {
    static let parser = Many(
        StartsWith<Substring>("ne").map { Coordinate(x: 1, y: 1) }
            .orElse(StartsWith("nw").map { Coordinate(x: -1, y: 1) })
            .orElse(StartsWith("se").map { Coordinate(x: 1, y: -1) })
            .orElse(StartsWith("sw").map { Coordinate(x: -1, y: -1) })
            .orElse(StartsWith("w").map { Coordinate(x: -2, y: 0) })
            .orElse(StartsWith("e").map { Coordinate(x: 2, y: 0) }),
        into: Coordinate.zero
    ) { $0 = $0 + $1 }
    .skip(Newline().pullback(\.utf8))

    static let input = parser.stream.parse(&stdinStream) ?? []
    func run() {
        var tiles = Dictionary(Self.input.map{ ($0, true) }) { a, b in !a }
        print("Part 1", tiles.filter(\.value).count)

        for _ in 0..<100 { tiles = tiles.step() }
        print("Part 2", tiles.filter(\.value).count)
    }
}
