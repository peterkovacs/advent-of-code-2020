
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

fileprivate extension Array where Element == Int {
    var score: Int {
        self.reversed().enumerated().reduce(into: 0) { $0 += ($1.offset + 1) * $1.element }
    }
}

struct Day22: ParsableCommand {
    static let parser = tuple <^>
        (string("Player 1:\n") *> oneOrMore(integer <* char("\n")) <* char("\n")) <*>
        (string("Player 2:\n") *> oneOrMore(integer <* char("\n")))
    static let (player1, player2) = try! FootlessParser.parse(parser, stdin.joined(separator: "\n") + "\n")

    func part1() {
        var (player1, player2) = (Self.player1, Self.player2)

        while !player1.isEmpty && !player2.isEmpty {
            if player1[0] > player2[0] {
                player1.append(player1.removeFirst())
                player1.append(player2.removeFirst())
            } else {
                player2.append(player2.removeFirst())
                player2.append(player1.removeFirst())
            }
        }

        let result = max( player1.score, player2.score )
        print("Part 1", result)
    }

    func part2() {
        func play(player1: [Int], player2: [Int]) -> (Int, Int) {
            struct State: Hashable { let p1: [Int], p2: [Int] }
            var (player1, player2) = (player1, player2)
            var played = Set<State>()

            while !player1.isEmpty, !player2.isEmpty {
                let (inserted, _) = played.insert(State(p1: player1, p2: player2))
                guard inserted else { return (player1.score, 0) }

                let (a, b) = (player1.removeFirst(), player2.removeFirst())
                if player1.count >= a, player2.count >= b {
                    let (scoreA, scoreB) = play(player1: Array(player1[0..<a]), player2: Array(player2[0..<b]))
                    if scoreA > scoreB {
                        player1.append(a)
                        player1.append(b)
                    } else {
                        player2.append(b)
                        player2.append(a)
                    }
                } else if a > b {
                    player1.append(a)
                    player1.append(b)
                } else {
                    player2.append(b)
                    player2.append(a)
                }
            }

            return (player1.score, player2.score)
        }

        print("Part 2", play(player1: Self.player1, player2: Self.player2))
    }

    func run() {
        part1()
        part2()
    }
}
