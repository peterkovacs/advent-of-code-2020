
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

struct Day6: ParsableCommand {
    func run() {
        let groups = Array(stdin).joined(separator: "\n").components(separatedBy: "\n\n").map { $0.split(separator: "\n") }
        print("Part 1", groups.map { Set($0.joined()) }.map(\.count).sum)
        print("Part 2", groups.map { $0.reduce(Set("abcdefghijklmnopqrstuvwxyz")) { $0.intersection($1) }}.map(\.count).sum )
    }
}
