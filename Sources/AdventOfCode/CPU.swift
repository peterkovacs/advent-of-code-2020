//
//  CPU.swift
//  
//
//  Created by Peter Kovacs on 12/8/20.
//

import Foundation
import FootlessParser

extension Dictionary where Key == String {
    public var parser: Parser<Character, Value> {
        return reduce( fail(.Mismatch(AnyCollection([]), "", "")) ) { accum, val in
            (string(val.key) >>- { _ in pure(val.value) }) <|> accum
        }
    }
}


public struct CPU {
    var pc: Int = 0
    var accumulator: Int = 0

    enum Instruction {
        case jmp(Int),
             nop(Int),
             acc(Int)

        var executable: (CPU) -> CPU {
            switch self {
            case .jmp(let arg): return { cpu in cpu.jmp(arg) }
            case .nop(let arg): return { cpu in cpu.nop(arg) }
            case .acc(let arg): return { cpu in cpu.acc(arg) }
            }
        }
    }

    static var parser = { () -> Parser<Character, Instruction> in
        let instruction = [
            "jmp": Instruction.jmp, "nop": Instruction.nop, "acc": Instruction.acc
        ].parser

        let result = curry { $0($1) } <^>
            instruction <*> (whitespace *> integer)

        return result
    }()

    static var program = oneOrMore((parser >>- { pure($0.executable) }) <* whitespacesOrNewline)

    func nop(_ arg: Int) -> CPU {
        var result = self
        result.pc += 1
        return result
    }

    func acc(_ arg: Int) -> CPU {
        var result = self
        result.accumulator += arg
        result.pc += 1
        return result
    }

    func jmp(_ arg: Int) -> CPU {
        var result = self
        result.pc += arg
        return result
    }
}
