
import Foundation
import ArgumentParser
import Algorithms

extension ArraySlice where Element == Int {
    var sum: Int { reduce(0, +) }
    var product: Int { reduce(1, *) }
}

struct Day9: ParsableCommand {
    @Option var preamble: Int = 25
    static let input = stdin.compactMap(Int.init)

    func part1() -> Int {
        Self.input[
            (preamble..<Self.input.count)
                .first { index in
                    !Self.input[
                        (index-self.preamble)..<index
                    ]
                    .combinations(ofCount: 2)
                    .contains { $0.sum == Self.input[index] }
                } ?? 0
        ]
    }

    func part2(_ value: Int) -> Int {
        func isWeakness(index: Int) -> Int? {
            for endIndex in (index+2)..<(Self.input.endIndex) {
                let sum = Self.input[index..<endIndex].sum
                if sum == value { return Self.input[index..<endIndex].min()! + Self.input[index..<endIndex].max()! }
                else if sum > value { return nil }
            }

            return nil
        }

        return Self.input.indices.lazy.compactMap(isWeakness(index:)).first ?? 0
    }

    func run() {
        print("Part 1", part1())
        print("Part 2", part2(part1()))
    }
}
