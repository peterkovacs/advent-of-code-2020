
import Foundation
import ArgumentParser
import Algorithms

struct Coord: Hashable, CustomStringConvertible {
    let x, y, z, w: Int

    typealias Neighbors2 = LazyMapSequence<
        LazySequence<
            Product2<
                ClosedRange<Int>,
                ClosedRange<Int>
            >
        >.Elements,
        Coord
    >
    var neighbors2: Neighbors2 {
        product(-1...1, -1...1)
            .lazy
            .map { Coord(x: $0.0 + x, y: $0.1 + y, z: z, w: w) }
    }

    typealias Neighbors3 = LazyMapSequence<
        LazySequence<
            Product2<
                Neighbors2,
                ClosedRange<Int>
            >
        >.Elements,
        Coord
    >
    var neighbors3: Neighbors3 {
        product(neighbors2, -1...1)
            .lazy
            .map { Coord(x: $0.0.x, y: $0.0.y, z: $0.1 + z, w: w) }
    }

    typealias Neighbors4 = LazyMapSequence<
        LazySequence<
            Product2<
                Neighbors3,
                ClosedRange<Int>
            >
        >.Elements,
        Coord
    >
    var neighbors4: Neighbors4 {
        product(neighbors3, -1...1)
            .lazy
            .map { Coord(x: $0.0.x, y: $0.0.y, z: $0.0.z, w: $0.1 + w) }
    }

    var description: String {
        "(\(x),\(y),\(z),\(w)"
    }
}

extension Set where Element == Coord {

    func iterator<T>(_ neighbors: @escaping (Coord) -> T) -> AnyIterator<Self> where T: Sequence, T.Element == Coord {
        var working = self
        return .init {
            var result = Set<Coord>()
            let regionOfInfluence = working.reduce(into: Set()) { $0.formUnion( neighbors($1) ) }

            regionOfInfluence.forEach { i in
                let isActive = working.contains(i)
                let activeNeighbors = neighbors(i)
                    .filter { $0 != i }
                    .filter { working.contains($0) }
                    .count
                if (activeNeighbors == 2 && isActive) || activeNeighbors == 3 { result.insert(i) }
            }

            working = result
            return result
        }

    }
}

struct Day17: ParsableCommand {
    static let input = Array(stdin)
    static let grid = Grid(
        input.joined().map { c -> Bool in
            switch c {
            case "#": return true
            case ".": return false
            default: fatalError()
            }
        },
        maxX: input[0].count,
        maxY: input.count
    )!

    static let coordinates = Set(grid.indices.filter { grid[$0] }.map { Coord(x: $0.x, y: $0.y, z: 0, w: 0) })

    func run() {
        for (i, set) in zip( 1...6, Self.coordinates.iterator(\.neighbors3) ) {
            print("Part 1: After \(i)", set.count)
        }

        for (i, set) in zip( 1...6, Self.coordinates.iterator(\.neighbors4) ) {
            print("Part 2: After \(i)", set.count)
        }
    }
}
