//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/1/20.
//

import Foundation
import ArgumentParser
import Algorithms

extension Array where Element == Int {
    var sum: Int { reduce(0, +) }
    var product: Int { reduce(1, *) }
}

struct Day1: ParsableCommand {
    static let input = Array(stdin.compactMap(Int.init))

    func run() {
        if let part1 = Self.input.combinations(ofCount: 2).first(where: { $0.sum == 2020 }) {
            print("Part 1", part1.product)
        }

        if let part2 = Self.input.combinations(ofCount: 3).first(where: { $0.sum == 2020 }) {
            print("Part 2", part2.product)
        }
    }
}
