
import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

let unsigned = { UInt($0)! } <^> oneOrMore(digit)

struct Day14: ParsableCommand {
    enum Instruction {
        case mask(UInt, UInt, [UInt])
        case memory(UInt, UInt)
    }

    static let parser =
        {
            Instruction.mask(
                $0.reduce(into: UInt(0)) {
                    if $1 == "1" { $0 |= 1 }
                    $0 <<= 1
                } >> 1,
                $0.reduce(into: UInt(0)) {
                    if $1 == "0" { $0 |= 1 }
                    $0 <<= 1
                } >> 1,
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
                mask = (ones: a, nonFloat: ~(~a & ~b) & 0x7FFFFFFF, float: c)
            case .memory(let pos, let value):
                for m in (0...mask.float.count).flatMap({ mask.float.combinations(ofCount: $0) }) {
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
