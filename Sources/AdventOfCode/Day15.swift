
import Foundation
import ArgumentParser
import Algorithms

struct Day15: ParsableCommand {
    @Option var input: String = "2,0,1,7,4,14,18"
    @Option var count = 2020

    var numbers: AnyIterator<Int> {
        var starting = input.components(separatedBy: ",").compactMap(Int.init)
        var numbers: [(Int, Int?)?] = Array(repeating: nil, count: count)

        var n = 0
        var i = 0

        return .init { 
            i += 1

            if !starting.isEmpty {
                n = starting.removeFirst()
                numbers[n] = (i, nil)
            } else {
                switch numbers[n] {
                case let .some((x, .some(y))):
                    n = x - y
                case .some((_, nil)):
                    n = 0
                case nil: fatalError()
                }
            }

            switch numbers[n] {
            case let .some((x, _)):
                numbers[n] = (i, x)
            case nil:
                numbers[n] = (i, nil)
            }

            return n
        }
    }


    func run() {
        print("Part 1", Array(numbers.dropFirst(count - 1).prefix(1)))
    }
}
