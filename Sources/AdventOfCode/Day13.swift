
import Foundation
import ArgumentParser
import Algorithms

struct Day13: ParsableCommand {
     static let input = Array(stdin)
    func part1() {
        let (target, busses) = (
            Int(Self.input[0])!,
            Self.input[1].components(separatedBy: ",").compactMap(Int.init)
        )

        let part1 = busses.map { busID -> (Int, Int) in
            if (target / busID) * busID < target {
                return (busID, (((target / busID) + 1) * busID) - target)
            } else {
                return (busID, ((target / busID) * busID) - target)
            }
        }.min(by: { $0.1 < $1.1 })!

        print("Part 1", part1.0 * part1.1)
    }

    func part2() {
        var busses =
            Self.input[1]
            .components(separatedBy: ",")
            .map(Int.init)
            .enumerated()
            .filter { $0.element != nil }
            .map { (offset: $0.offset % $0.element!, element: $0.element!) }[...]

        var (initial, multiplier) = busses.removeFirst()

        let t = sequence(first: initial, next: { $0 + multiplier }).first { timestamp in
            let (offset, id) = busses[busses.startIndex]

            if timestamp % id == (id - offset) {
                multiplier *= id
                busses = busses.dropFirst()
            }

            return busses.isEmpty
        }

        print("Part 2", t!)
    }

    func run() throws {
        part1()
        part2()
    }
}
