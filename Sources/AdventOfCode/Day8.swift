//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/8/20.
//

import Foundation
import ArgumentParser
import Algorithms
import FootlessParser

fileprivate extension Array where Element == CPU.Instruction {
    func swappingAt(_ index: Self.Index) -> Self {
        var result = self
        switch result[index] {
        case .jmp(let val): result[index] = .nop(val)
        case .nop(let val): result[index] = .jmp(val)
        case .acc: break
        }
        return result
    }
}

struct Day8: ParsableCommand {
    static let input = stdin.map { try! FootlessParser.parse(CPU.parser, $0) }

    func run(_ instructions: [CPU.Instruction]) -> CPU {
        let program = instructions.map(\.executable)
        var set = Set<Int>()
        var cpu = CPU()

        while !set.contains(cpu.pc), program.indices.contains(cpu.pc) {
            set.insert(cpu.pc)
            cpu = program[cpu.pc](cpu)
        }

        return cpu
    }

    func part1() {
        let cpu = run(Self.input)
        print("Part 1", cpu.accumulator)
    }

    func part2() {
        let result = Self.input.indices.lazy
            .filter {
                switch Self.input[$0] {
                case .jmp, .nop: return true
                case .acc: return false
                }
            }
            .map { run(Self.input.swappingAt($0)) }
            .first { !Self.input.indices.contains($0.pc) }

        print("Part 2", result?.accumulator as Any)
    }
    
    func run() throws  {
        part1()
        part2()
    }
}
