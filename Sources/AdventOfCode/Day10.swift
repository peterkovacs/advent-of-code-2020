
import Foundation
import ArgumentParser
import Algorithms


fileprivate extension ArraySlice where Element == Int {
    private static var known = [ArraySlice<Int>.Index: Int]()

    func arrangements() -> Int {
        if let count = Self.known[startIndex] { return count }
        if startIndex + 1 == endIndex { return 1 }

        let p = self.dropFirst().partitioningIndex(where: { !(1...3).contains($0 - self[startIndex]) })

        let result = ((startIndex+1)..<p).reduce(into: 0) { $0 += self[$1...].arrangements() }
        Self.known[startIndex] = result

        return result
    }
}

struct Day10: ParsableCommand {
    static let input = stdin.compactMap(Int.init).sorted()
    func run() {
        let device = Self.input.last! + 3
        let input = [0] + Self.input + [device]
        let differences = zip(input, input.dropFirst()).reduce(into: (0, 0)) {
            switch $1.1 - $1.0 {
            case 1: $0.0 += 1
            case 3: $0.1 += 1
            default: fatalError()
            }
        }

        print("Part 1", differences, differences.0 * differences.1)
        print("Part 2", input[...].arrangements())
    }
}
