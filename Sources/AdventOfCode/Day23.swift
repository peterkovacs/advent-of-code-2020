
import Foundation
import ArgumentParser
import Algorithms

class Node<Element: Equatable>: Sequence {
    var value: Element
    var next: Node!
    init(value: Element, next: Node) {
        self.value = value
        self.next = next
    }

    init?(_ array: [Element]) {
        guard !array.isEmpty else { return nil }
        self.value = array[0]
        self.next = array.dropFirst().reversed().reduce(self) { Node(value: $1, next: $0) }
    }

    func makeIterator() -> UnfoldSequence<Node, (Node?, Bool)> {
        sequence(first: self, next: \.next)
    }
}

struct Day23: ParsableCommand {
    @Option var input: String = "459672813"
    @Option var n: Int = 1_000_000
    @Option var count: Int = 10_000_000

    func part1() {
        let cups = Node(input.compactMap({ Int("\($0)") }))!
        let positions = Dictionary(uniqueKeysWithValues: cups.prefix(input.count).map { ($0.value, $0) })

        var current = cups

        func move() {
            let pickup = current.next!
            current.next = pickup.next.next.next

            func find(destination: Int) -> Node<Int> {
                guard (1...9).contains(destination) else { return find(destination: 9) }
                if destination == pickup.value || destination == pickup.next.value || destination == pickup.next.next.value {
                    return find(destination: destination - 1)
                }

                return positions[destination]!
            }

            let d = find(destination: current.value - 1)
            let temp = d.next
            d.next = pickup
            pickup.next.next.next = temp

            current = current.next!
        }

        for _ in 0..<100 { move() }
        print(current.first(where: { $0.value == 1 })!.prefix(input.count).dropFirst().map { "\($0.value)" }.joined(separator: ""))
    }

    func part2() {
        let cups = Node(input.compactMap { Int("\($0)")! } + Array(10...n))!
        let positions = Dictionary(uniqueKeysWithValues: cups.prefix(n).map { ($0.value, $0) })

        var current = cups

        func move(_ index: Int) {
            let pickup = current.next!
            current.next = pickup.next.next.next

            func find(destination: Int) -> Node<Int> {
                guard (1...n).contains(destination) else { return find(destination: n) }
                if destination == pickup.value || destination == pickup.next.value || destination == pickup.next.next.value {
                    return find(destination: destination - 1)
                }

                return positions[destination]!
            }

            let d = find(destination: current.value - 1)
            let temp = d.next
            d.next = pickup
            pickup.next.next.next = temp

            current = current.next!
        }

        for i in 0..<count {
            move(i)
        }

        print( current.first(where: { $0.value == 1 })!.dropFirst().prefix(2).map(\.value).product )
    }

    func run() throws {
        part1()
        part2()
    }
}
