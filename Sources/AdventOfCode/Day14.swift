
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

let unsigned = { UInt($0)! } <^> oneOrMore(digit)

extension Collection where Indices == Range<Int> {
    /// Returns all combinations of each size in range
    func combinations(range: Indices) -> AnyIterator<[Element]> {
        var n = range.startIndex
        var iterator = combinations(ofCount: n).makeIterator()
        return .init {
            if let next = iterator.next() { return next }
            n += 1
            guard n <= range.endIndex else { return nil }

            iterator = combinations(ofCount: n).makeIterator()
            return iterator.next()
        }
    }

    /// Returns all combinations of each size in 0...count
    func combinations() -> AnyIterator<[Element]> {
        return combinations(range: indices)
    }
}

struct Day14: ParsableCommand {
    enum Instruction {
        case mask(UInt, UInt, [UInt])
        case memory(UInt, UInt)
    }

    static let parser =
        {
            Instruction.mask(
                $0.reversed().enumerated().reduce(into: UInt(0)) {
                    if $1.element == "1" { $0 |= (1 << $1.offset) }
                },
                $0.reversed().enumerated().reduce(into: UInt(0)) {
                    if $1.element == "0" { $0 |= (1 << $1.offset) }
                },
                $0.reversed().enumerated().reduce(into: []) {
                    if $1.element == "X" { $0.append(UInt(1) << $1.offset) }
                }
            )
        } <^> (string("mask = ") *> oneOrMore(oneOf("10X"))) <|>
        (curry(Instruction.memory) <^> (string("mem[") *> unsigned) <*> (string("] = ") *> unsigned))

    static let input = stdin.compactMap { try? FootlessParser.parse( parser, $0 ) }

    func part1() {
        var mask = (0, 0) as (UInt, UInt)
        var memory: [UInt: UInt] = [:]

        for instruction in Self.input {
            switch instruction {
            case .mask(let a, let b, _): mask = (a, b)
            case .memory(let pos, let value):
                memory[pos] = (value | mask.0) & ~mask.1
            }
        }

        print("Part 1", memory.values.reduce(0, +))
    }

    func part2() {
        var mask = (ones: UInt(0), nonFloat: UInt(0), float: [] as [UInt])
        var memory: [UInt: UInt] = [:]

        for instruction in Self.input {
            switch instruction {
            case .mask(let a, let b, let c):
                mask = (ones: a, nonFloat: ~(~a & ~b), float: c)
            case .memory(let pos, let value):
                for m in mask.float.combinations() {
                    memory[
                        (pos & mask.nonFloat) | mask.ones | m.reduce(0, { $0 | $1 })
                    ] = value
                }
            }
        }

        print("Part 2", memory.values.reduce(0, +))
    }

    func run() throws {
        part1()
        part2()
    }
}
