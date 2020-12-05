
import Foundation
import ArgumentParser
import Algorithms

extension ClosedRange where Bound == Int {
    var midPoint: Bound {
        lowerBound + (upperBound - lowerBound) / 2
    }
}

fileprivate extension ClosedRange where Bound == Int {
    subscript(_ character: Character) -> Self {
        switch character {
        case "F", "L": return lowerBound...midPoint
        case "B", "R": return (midPoint + 1)...upperBound
        default: return self
        }
    }
}

fileprivate extension Array where Element == Character {
    var seatID: Int {
        let row = self[0...6].reduce(0...127) { $0[$1] }
        let seat = self[7...9].reduce(0...7) { $0[$1] }
        return row.lowerBound * 8 + seat.lowerBound
    }
}

struct Day5: ParsableCommand {
    static let input = Array(stdin.map{ Array($0) })

    func run() {
        let seatIDs = Self.input.map(\.seatID).sorted()
        print("Part 1", seatIDs.last as Any)

        let part2 = (seatIDs.indices.dropLast().map { (seatIDs[$0], seatIDs[$0+1]) } as [(Int, Int)])
            .first(where: { $0.0 == $0.1 - 2 })?.0.advanced(by: 1)
        print("Part 2", part2 as Any)
    }
}
